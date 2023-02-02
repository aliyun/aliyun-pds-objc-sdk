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
#import "PDSTestConfig.h"
#import <extobjc/EXTobjc.h>
#import "SDListViewController.h"
#import "SDDiagnoseViewController.h"

@import PDS_SDK;

@interface SDViewController ()
@property(weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property(weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property(weak, nonatomic) IBOutlet UILabel *downloadStatusLabel;
@property(weak, nonatomic) IBOutlet UILabel *uploadStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *startUploadButton;
@property (weak, nonatomic) IBOutlet UIButton *startDownloadButton;

@property(nonatomic, strong) PDSDownloadTask *downloadTask;
@property(nonatomic, strong) PDSUploadTask *uploadTask;

@property(nonatomic, strong) PDSTestConfig *config;
@end

@implementation SDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    self.config = [[PDSTestConfig alloc] init];
    self.uploadProgressView.progress = 0;
    self.downloadProgressView.progress = 0;
}

- (IBAction)startDownloadAction:(UIButton *)sender {
    self.startDownloadButton.enabled = NO;
    if (self.downloadTask) {
        [self.downloadTask cancel];
    }
    NSURL *documentUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    documentUrl = [documentUrl URLByAppendingPathComponent:@"download/WeChatMac.dmg"];
    PDSDownloadUrlRequest *request = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:@"https://dldir1.qq.com/weixin/mac/WeChatMac.dmg" destination:documentUrl.path fileSize:141830090 fileID:@"" hashValue:@"5b813cf4fd285088440c3f58d74c772d72c6a326" hashType:PDSFileHashTypeSha1 driveID:@"" shareID:nil shareToken:nil revisionId:nil sharePassword:nil];
    self.downloadTask = [[PDSClientManager defaultClient].file downloadUrl:request taskIdentifier:nil];
    @weakify(self);
    [self.downloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        @strongify(self);
        self.downloadProgressView.progress = totalBytesWritten / (float) totalBytesExpectedToWrite;
    }];
    [self.downloadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *networkError, NSString *taskIdentifier) {
        @strongify(self);
        self.startDownloadButton.enabled = YES;
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
    [self.config refreshSample];
    PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:self.config.samplePath
                                                                                  parentFileID:self.config.parentID
                                                                                        fileID:nil
                                                                                       driveID:self.config.driveID
                                                                                       shareID:nil
                                                                                      fileName:nil
                                                                                 checkNameMode:nil
                                                                                    shareToken:nil sharePassword:nil];
    @weakify(self);
    self.uploadTask = [[[[PDSClientManager defaultClient].file uploadFile:uploadFileRequest
                                                           taskIdentifier:nil]
            setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, NSString *taskIdentifier) {
                @strongify(self);
                self.uploadStatusLabel.text = [NSString stringWithFormat:@"上传%@%@",
                                                                         requestError ? @"@失败" : @"@成功",
                                                                         requestError ? requestError.description : @""];
                self.startUploadButton.enabled = YES;
            }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        @strongify(self);
        self.uploadStatusLabel.text = @"上传中";
        self.uploadProgressView.progress = totalBytesWritten / (float) totalBytesExpectedToWrite;
    }];
}

- (IBAction)pauseUpload:(id)sender {
    [self.uploadTask suspend];
}

- (IBAction)cancelUpload:(id)sender {
    [self.uploadTask cancel];
}
- (IBAction)listFile:(id)sender {
    SDListViewController *vc= [[SDListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)netDiagnose:(id)sender {
    SDDiagnoseViewController *vc = [[SDDiagnoseViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
