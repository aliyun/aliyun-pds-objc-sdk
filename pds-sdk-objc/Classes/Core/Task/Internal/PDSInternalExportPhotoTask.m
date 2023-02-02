//
// /*
// * Copyright 2009-2021 Alibaba Cloud All rights reserved.
// *
// * Licensed under the Apache License, Version 2.0 (the "License");
// * you may not use this file except in compliance with the License.
// * You may obtain a copy of the License at
// *
// *      http://www.apache.org/licenses/LICENSE-2.0
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// *

#import "PDSInternalExportPhotoTask.h"
@import Photos;
#import <Photos/Photos.h>
#import "PDSMacro.h"
#import "PDSError.h"
#import "NSError+PDS.h"
#import "NSFileManager+PDS.h"
#import "PHAssetResource+PDS.h"

@interface PDSInternalExportPhotoTask ()
// 需要导出的照片ID
@property(nonatomic, copy) NSString *photoLocalIdentifier;
// 任务是否已经被取消
@property(nonatomic, assign) BOOL cancelled;
// 任务是否完成
@property(nonatomic, assign) BOOL finished;
// 导出照片的队列
@property(nonatomic, strong) dispatch_queue_t exportOperationQueue;
// 导出照片的本地路径
@property(nonatomic, copy) NSString *savePath;
// 导出照片的存储目录
@property(nonatomic, readonly) NSString *outputDirPath;
// 照片asset
@property(nonatomic, strong) PHAsset *asset;
// 照片asset下面要导出的资源
@property(nonatomic, strong) PHAssetResource *assetResource;
// 是否导出成功
@property(nonatomic, assign) BOOL success;
// 导出过程中发生的错误
@property(nonatomic, strong) NSError *error;
@end

@implementation PDSInternalExportPhotoTask {
    PDSInternalExportPhotoResponseBlock _responseBlock;
    NSOperationQueue *_responseBlockQueue;
}
@synthesize retryCount;

- (id)initWithPhotoLocalIdentifier:(NSString *)photoLocalIdentifier {
    self = [self init];
    if (self) {
        self.photoLocalIdentifier = photoLocalIdentifier;
        [self setup];
    }
    return self;
}

- (void)setup {
    dispatch_queue_attr_t qosAttribute =
            dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
    self.exportOperationQueue =
            dispatch_queue_create("com.aliyun.pds.PDSInternalHashTask.queue", qosAttribute);
}

#pragma mark Task Control

- (void)cancel {
    @synchronized (self) {
        if (self.finished || self.cancelled) {
            return;
        }
        self.cancelled = YES;
        [self cleanup];
    }
}

- (void)suspend {
    [self cancel];//导出照片没有暂停，直接取消
}

- (void)resume {
    @synchronized (self) {
        if (self.finished || self.cancelled) {
            return;
        }
        [self _start];
    }
}

- (void)start {
    [self resume];
}

- (void)cleanup {
    @synchronized (self) {
        if (!PDSIsEmpty(self.savePath)) {
            [[NSFileManager defaultManager] removeItemAtPath:self.savePath error:nil];
        }
    }
}

- (id <PDSInternalTask>)restart {
    PDSInternalExportPhotoTask *task = [[PDSInternalExportPhotoTask alloc] initWithPhotoLocalIdentifier:self.photoLocalIdentifier];
    [task resume];
    return task;
}

#pragma mark Private Method

- (void)_start {
    if (![self prepareEnv]) {
        [self callResponseBlockIfNeeded];
        return;
    }
    [self exportPhoto];
}

- (void)exportPhoto {
    if ([self alreadyExported]) {//之前已经导出了这个文件
        @synchronized (self) {
            self.finished = YES;
            self.success = YES;
            [self callResponseBlockIfNeeded];
            return;
        }
    }
    PHAssetResource *assetResource = nil;
    PHAsset *asset = nil;
    NSString *savePath = nil;
    @synchronized (self) {
        assetResource = self.assetResource;
        asset = self.asset;
        savePath = self.savePath;
    }
    PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
    options.networkAccessAllowed = YES;
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:assetResource toFile:[NSURL fileURLWithPath:savePath]
                                                               options:options completionHandler:^(NSError *_Nullable error) {
         if (error == nil) {//导出成功
             @synchronized (self) {
                 self.success = YES;
                 self.finished = YES;
                 [self callResponseBlockIfNeeded];
                 return;
             }
         } else {//导出失败
             @synchronized (self) {
                 self.error = [NSError pds_errorWithCode:PDSErrorExportPhotoAssetFailed];
                 self.finished = YES;
                 [self callResponseBlockIfNeeded];
             }
         }
     }];
}

- (BOOL)prepareEnv {
    if (![self prepareOutputDir]) {
        return NO;
    }
    if (![self prepareAsset]) {
        return NO;
    }
    return YES;
}

- (BOOL)prepareOutputDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = YES;
    if(![fileManager fileExistsAtPath:self.outputDirPath]) {
        success = [fileManager createDirectoryAtPath:self.outputDirPath
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:nil];
    }
    if (!success) {
        @synchronized (self) {
            self.error = [NSError pds_errorWithCode:PDSErrorFileCreatedFailed];
            self.finished = YES;
        }
    }
    return success;
}

- (BOOL)prepareAsset {
    if (PDSIsEmpty(self.photoLocalIdentifier)) {
        @synchronized (self) {
            self.error = [NSError pds_errorWithCode:PDSErrorExportPhotoAssetFailed];
            self.finished = YES;
        }
        return NO;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.photoLocalIdentifier] options:nil];
    if (result.count <= 0) {//找不到对应的照片
        @synchronized (self) {
            self.error = [NSError pds_errorWithCode:PDSErrorExportPhotoAssetFailed];
            self.finished = YES;
        }
        return NO;
    }
    PHAsset *asset = result.firstObject;
    __block PHAssetResource *resource = nil;
    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        resource = resources.firstObject;
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        [resources enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAssetResource *assetResource, NSUInteger idx, BOOL *stop) {
            if (assetResource.type == PHAssetMediaTypeVideo) {
                resource = assetResource;
                *stop = YES;
            }
        }];
    } else {//格式不支持
        @synchronized (self) {
            self.error = [NSError pds_errorWithCode:PDSErrorExportUnsupportedFormat];
            self.finished = YES;
        }
        return NO;
    }

    if (!resource) {//没有找到对应的资源
        @synchronized (self) {
            self.error = [NSError pds_errorWithCode:PDSErrorExportPhotoAssetFailed];
            self.finished = YES;
        }
        return NO;
    }
    @synchronized (self) {
        self.assetResource = resource;
        self.asset = asset;
        self.savePath = [self.outputDirPath stringByAppendingPathComponent:self.assetResource.originalFilename];
    }
    return YES;
}

- (BOOL)alreadyExported {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.savePath]) {
        uint64_t localFileSize = [fileManager pds_fileSizeForPath:self.savePath];
        return localFileSize == [self.assetResource pds_fileSize];
    }
    return NO;
}

#pragma mark Properties

- (NSString *)outputDirPath {
    NSString *storagePath = PDSSDKStorageFolderPath();
    NSString *outputPath = [storagePath stringByAppendingPathComponent:@"assets"];
    return outputPath;
}

#pragma mark Response Callback

- (void)setResponseBlock:(PDSInternalExportPhotoResponseBlock)responseBlock {
    [self setResponseBlock:responseBlock queue:nil];
}

- (void)setResponseBlock:(PDSInternalExportPhotoResponseBlock)responseBlock queue:(NSOperationQueue *_Nullable)queue {
    @synchronized (self) {
        self->_responseBlock = responseBlock;
        self->_responseBlockQueue = queue;
        [self callResponseBlockIfNeeded];
    }
}

- (void)callResponseBlockIfNeeded {
    __block PDSInternalExportPhotoResponseBlock responseBlock = nil;
    __block NSOperationQueue *queue = nil;
    NSError *error = nil;
    __block NSString *savePath = nil;
    __block NSString *fileName = self.assetResource.originalFilename;
    __block BOOL finished = NO;
    __block BOOL success = NO;
    __block BOOL cancelled = NO;
    @synchronized (self) {
        responseBlock = self->_responseBlock;
        queue = self->_responseBlockQueue ?: [NSOperationQueue mainQueue];
        error = self.error;
        finished = self.finished;
        savePath = self.savePath;
        success = self.success;
        cancelled = self.cancelled;
    }
    if (finished && responseBlock && !cancelled) {
        [queue addOperationWithBlock:^{
            responseBlock(success, savePath, fileName, error);
        }];
    }
}
@end
