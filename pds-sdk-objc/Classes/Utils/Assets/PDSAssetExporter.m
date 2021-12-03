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

#import <Photos/Photos.h>
#import "PDSAssetExporter.h"
#import "NSFileManager+PDS.h"
#import "PDSMacro.h"


@implementation PDSAssetExporter {

}
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (void)exportAssetWithIdentifier:(NSString *)identifier toPath:(NSString *)outputPath completion:(PDSAssetExportCompletion)completion {
    if (PDSIsEmpty(identifier)) {

    }
}

- (void)exportAsset:(PHAsset *)asset toPath:(NSString *)outputPath completion:(PDSAssetExportCompletion)completion {
    if (!asset || !outputPath) {
        if (completion) {
        }
        return;
    }
    [[NSFileManager defaultManager] pds_removeItemAtPath:outputPath];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        //TODO 针对图片，取data写本地url
    } else {
        //TODO 针对视频，直接写文件到本地url
    }
}


- (void)cancelAssetExportByRequestID:(NSString *)requestId {

}

#pragma mark Private Method
@end