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

#import "SDViewController.h"
#import <extobjc/EXTobjc.h>
@import PDS_SDK;

@interface SDViewController ()
@property(weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property(weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property(weak, nonatomic) IBOutlet UILabel *downloadStatusLabel;
@property(weak, nonatomic) IBOutlet UILabel *uploadStatusLabel;
@property(nonatomic, strong) PDSDownloadTask *downloadTask;
@property(nonatomic, strong) PDSUploadTask *uploadTask;
@property(nonatomic, copy) NSDictionary *config;
@property(nonatomic, copy) NSString *samplePath;
@end

@implementation SDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    NSData *configData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"config" withExtension:@"json"]];
    self.config = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingFragmentsAllowed error:nil];
    PDSClientConfig *clientConfig = [[PDSClientConfig alloc] initWithHost:self.config[@"host"] userAgent:self.config[@"user_agent"]];
    [PDSClientManager setupWithAccessToken:self.config[@"access_token"] clientConfig:clientConfig];

    self.samplePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@""];
    self.uploadProgressView.progress = 0;
    self.downloadProgressView.progress = 0;
}

- (IBAction)startDownloadAction:(UIButton *)sender {
    sender.enabled = NO;
    if (self.downloadTask) {
        [self.downloadTask cancel];
    }
    NSURL *documentUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    documentUrl = [documentUrl URLByAppendingPathComponent:@"download/WeChatMac.dmg"];
    PDSDownloadUrlRequest *request = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:@"https://dldir1.qq.com/weixin/mac/WeChatMac.dmg" destination:documentUrl.path fileSize:141830090 fileID:@"10293783" hashValue:@"5b813cf4fd285088440c3f58d74c772d72c6a326" hashType:PDSFileHashTypeSha1 driveID:nil shareID:nil];
    self.downloadTask = [[PDSClientManager defaultClient].file downloadUrl:request taskIdentifier:nil];
    @weakify(self);
    [self.downloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        @strongify(self);
       self.downloadProgressView.progress = totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
    [self.downloadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *networkError, NSString *taskIdentifier) {
        sender.enabled = YES;
    }];
}

- (IBAction)pauseDownloadAction:(id)sender {
    if (self.downloadTask) {
        [self.downloadTask suspend];
    }
}

- (IBAction)cancelDownloadAction:(id)sender {
    if (self.downloadTask) {
        [self.downloadTask cancel];
    }
}

- (IBAction)startUpload:(id)sender {
    if (self.uploadTask) {
        return;
    }
    PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:self.samplePath
                                                                                  parentFileID:self.config[@"parent_file_id"] driveID:self.config[@"drive_id"] shareID:nil fileName:nil];
    self.uploadTask = [[[[PDSClientManager defaultClient].file uploadFile:uploadFileRequest
                                                          taskIdentifier:nil]
            setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
        self.uploadStatusLabel.text = @"上传完成";
            }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        self.uploadStatusLabel.text = @"上传中";
        self.uploadProgressView.progress = totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
}

- (IBAction)pauseUpload:(id)sender {
    [self.uploadTask suspend];
}

- (IBAction)cancelUpload:(id)sender {
    [self.uploadTask cancel];
}

@end
