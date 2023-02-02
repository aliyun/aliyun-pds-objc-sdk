//
//  PDSUploadTaskRequest.m
//  PDSSystemInspector
//
//  Created by issuser on 2022/12/18.
//

#import "PDSTaskRequest.h"
#import <extobjc/EXTobjc.h>
#import "PDSDownloadTask.h"
#import "PDSUploadTask.h"
#import "PDSCustomParameters.h"
#import "PDSUploadFileRequest.h"
#import "PDSDownloadUrlRequest.h"
#import "PDSClientManager.h"
#import "PDSUserClient.h"
#import "PDSRequestError.h"
#import "PDSAPIDeleteFileRequest.h"
#import "PDSConstants.h"
#import "PDSInspectTool.h"
#import "PDSFileSession.h"
#import "PDSFileMetadata.h"
#import "PDSInspectResult.h"

@interface PDSTaskRequest ()

@property (nonatomic, strong) NSDate *lastDate;

@property (nonatomic, copy) NSString *fileId;

@property (nonatomic, copy) NSString *hashValue;

@property (nonatomic, assign) uint64_t fileSize;

@property (nonatomic, copy) NSString *filePath;

@property(nonatomic, strong) PDSDownloadTask *downloadTask;

@property(nonatomic, strong) PDSUploadTask *uploadTask;

@property(nonatomic,strong) PDSAPIRequestTask<PDSAPIDeleteFileResponse *> * deleteFileTask;

@end

@implementation PDSTaskRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        self.filePath = [docPath stringByAppendingPathComponent:@"myInspect.txt"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath] == NO) {
            NSString *string = [NSString stringWithFormat:@"%@464636363543524",self.filePath];
            [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:[NSData dataWithData:[string dataUsingEncoding:NSUTF8StringEncoding]] attributes:nil];
        }
        self.hashValue = [PDSFileHash sha1HashOfFileAtPath:self.filePath];
    }
    return self;
}

- (void)requestUploadCustomParameters:(PDSCustomParameters *)customParameters progressBlock:(PDSFileProgressBlock)progressBlock resonseBlock:(void (^)(PDSInspectResult *result))block {
    
    NSDate *startDate = [NSDate date];
    __block int64_t totalBytes;
    NSString *fileId = [NSString stringWithFormat:@"%u",arc4random() % 100];
    PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:self.filePath parentFileID:@"root" fileID:@"" driveID:customParameters.driveId shareID:@"" fileName:nil checkNameMode:nil shareToken:nil sharePassword:nil];
    self.fileSize = uploadFileRequest.fileSize;
    @weakify(self);
    self.uploadTask = [[[[PDSClientManager defaultClient].file uploadFile:uploadFileRequest taskIdentifier:fileId] setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
        @strongify(self);
        PDSInspectResult *detectResult = [[PDSInspectResult alloc] init];
        if (requestError == nil) {
            self.fileId = result.fileID;
            [self removeLocalFile];
            double time = [[NSDate date] timeIntervalSinceDate:startDate];
            long long speed = totalBytes / time;
            NSString *speedStr = [NSString stringWithFormat:@"%@/s",[PDSInspectTool converFileSize:speed]];
            detectResult.success = YES;
            detectResult.content = [NSString stringWithFormat:@"%@",speedStr];
        } else {
            detectResult.success = NO;
            detectResult.errorMessage = requestError.message;
        }
        block(detectResult);
    }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        totalBytes = totalBytesExpectedToWrite;
        if (progressBlock) {
            progressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        }
    }];
}

- (void)requestDownloadCustomParameters:(PDSCustomParameters *)customParameters progressBlock:(PDSFileProgressBlock)progressBlock resonseBlock:(PDSFileCompleteBlock)block {
    
    PDSDownloadUrlRequest *requestUrl = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:@"" destination:self.filePath fileSize:self.fileSize fileID:self.fileId hashValue:self.hashValue hashType:PDSFileHashTypeSha1 driveID:customParameters.driveId shareID:nil shareToken:nil revisionId:nil sharePassword:nil];
    self.downloadTask = [[PDSClientManager defaultClient].file downloadUrl:requestUrl taskIdentifier:self.fileId];
    NSDate *startDate = [NSDate date];
    __block int64_t totalBytes;
    [self.downloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        if (progressBlock) {
            progressBlock(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        }
    }];
    @weakify(self);
    [self.downloadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *networkError, NSString *taskIdentifier) {
        @strongify(self);
        PDSInspectResult *detectResult = [[PDSInspectResult alloc] init];
        if (networkError == nil) {
            double time = [[NSDate date] timeIntervalSinceDate:startDate];
            long long speed = totalBytes / time;
            NSString *speedStr = [NSString stringWithFormat:@"%@/s",[PDSInspectTool converFileSize:speed]];
            detectResult.success = YES;
            detectResult.content = [NSString stringWithFormat:@"%@",speedStr];
        } else {
            detectResult.success = NO;
            detectResult.errorMessage = networkError.message;
        }
        block(detectResult);
    }];
}

- (void)requestDeleteFileCustomParameters:(PDSCustomParameters *)customParameters resonseBlock:(void(^)(BOOL))block {
    PDSAPIDeleteFileRequest *deleteFileRequest = [[PDSAPIDeleteFileRequest alloc] initWithDriveID: customParameters.driveId fileID:self.fileId permanently:YES];
    self.deleteFileTask = [[PDSClientManager defaultClient].file deleteFile:deleteFileRequest];
    @weakify(self);
    [self.deleteFileTask setResponseBlock:^(PDSAPIDeleteFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
        @strongify(self);
        if (requestError == nil) {
            [self removeLocalFile];
            block(YES);
        } else {
            block(NO);
        }
    }];
}

- (void)removeLocalFile {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:&error];
    if (error) {
        NSLog(@"error remove upload file = %@",error.description);
    }
}

- (void)cancel{
    [self.uploadTask cancel];
    [self.downloadTask cancel];
}

@end
