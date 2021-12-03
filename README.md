# PDS Objective-C SDK 说明
## 介绍

## 安装
本SDK支持通过cocoapods进行安装
``` pod 'pds-objc-sdk' ```

## 使用说明
### 初始化
```
    PDSClientConfig *clientConfig = [[PDSClientConfig alloc] initWithHost:@"host" userAgent:nil];
    [PDSClientManager setupWithAccessToken:@"token" clientConfig:clientConfig];
```
clientConfig用于PDS SDK的初始化配置，host和accessToken必须填写，host是指API host，请在PDS控制台获取你的 api host。accessToken是指访问鉴权的token，需要业务方后端使用 PDS 平台申请的 appKey & appSecret 换取 token 返回给客户端
由于accessToken每隔两个小时就会过期，因此使用方还需要定时通过[[PDSClientManager defaultClient] setAccessToken:]方法更新SDK内部的accessToken
### 常用接口
#### 上传文件
```
PDSUploadFileRequest *uploadFileRequest = [[PDSUploadFileRequest alloc] initWithUploadPath:testConfig.samplePath                                                                    userID:testConfig.userID                                                                           parentFileID:testConfig.parentID                                                                                           driveID:testConfig.driveID                                                                                           shareID:nil                                                                                          fileName:nil];
uploadTask = [[PDSClientManager defaultClient].file uploadFile:uploadFileRequest taskIdentifier:nil];
[uploadTask setResponseBlock:^(PDSFileMetadata *result, PDSRequestError *requestError, PDSUploadFileRequest *request, NSString *taskIdentifier) {
//完成回调
            }];
```
通过request创建task以后，需要将task保存起来，否则task本身会被内存回收导致上传失败。
上传任务支持断点续传，只需要在第一次创建上传任务以后保存返回的task的taskIdentifier，下次创建任务的时候将taskIdentifier传入SDK就会从上一次的上传进度开始恢复上传。
上传任务支持cancel/suspend/resume/restart操作，cancel和suspend的区别在于，cancel表示取消这个任务，SDK会将上传记录/缓存文件全部清除，任务状态变成finish。无法resume恢复上传，只支持restart重新创建一个从零开始的新的上传任务。
suspend只是表示暂停上传，可以随时调用resume方法恢复上传，通常用于wifi/移动网络环境切换场景下面的暂停操作。


#### 下载文件
```
PDSDownloadUrlRequest *downloadUrlRequest = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:testConfig.downloadUrl
destination:destinationDirPath
userID:testConfig.userID
parentID:testConfig.parentID
fileSize:testConfig.downloadSize
fileID:testConfig.downloadFileID
hashValue:testConfig.downloadHash
hashType:PDSFileHashTypeSha1
driveID:testConfig.driveID
shareID:nil];
downloadTask = [[PDSClientManager defaultClient].file downloadUrl:downloadUrlRequest taskIdentifier:nil];
 [downloadTask setResponseBlock:^(PDSFileMetadata * _Nullable result, PDSRequestError * _Nullable networkError, PDSDownloadUrlRequest * _Nonnull request, NSString * _Nonnull taskIdentifier) {
//下载完成回调
            }];
```
通过request创建task以后，需要将task保存起来，否则task本身会被内存回收导致下载失败。
下载任务支持断点续传，只需要在第一次创建下载任务以后保存返回的task的taskIdentifier，下次创建任务的时候将taskIdentifier传入SDK就会从上一次的下载进度开始恢复下载。
下载任务支持cancel/suspend/resume/restart操作，cancel和suspend的区别在于，cancel表示取消这个任务，SDK会将下载记录/缓存文件全部清除，任务状态变成finish。无法resume恢复下载，只支持restart重新创建一个从零开始的新的下载任务。
suspend只是表示暂停下载，可以随时调用resume方法恢复下载，通常用于wifi/移动网络环境切换场景下面的暂停操作。
#### 文件接口
常用的文件接口可以通过`[PDSClientManager defaultClient].file`下面的类方法进行调用。
目前支持的文件操作包括
Complete
Create 
Move 
Delete
Copy
Update
Get
GetDownloadUrl
GetUploadUrl
GetAsyncTask
具体的接口说明见[阿里云官方文档](https://help.aliyun.com/document_detail/175927.html)

## 更新日志
0.0.1 2021-12-01
1. 第一版，支持文件上传下载/基本文件操作
