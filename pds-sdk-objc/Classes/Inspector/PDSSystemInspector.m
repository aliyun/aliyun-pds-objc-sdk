//
//  PDSNetDiagnoserManager.m
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#import "PDSSystemInspector.h"
#import "PDSInspectPing.h"
#import "PDSInspectTool.h"
#import "PDSInspectDNS.h"
#import "PDSInspectDeviceInfo.h"
#import "PDSNetworkRequest.h"
#import "PDSConstants.h"
#import "PDSCustomParameters.h"
#import "PDSTaskRequest.h"
#import <extobjc/EXTobjc.h>

#define MyDomainAddress  @"https://bj1093.apps.aliyunfile.com"

#define PDSDispatch_Main(block) dispatch_async(dispatch_get_main_queue(), block);

@interface PDSSystemInspector ()

@property (nonatomic, assign) BOOL isRunning;

@property (nonatomic, strong) NSDate *lastDate;

@property (nonatomic, strong) PDSInspectResult *result;

@property (nonatomic, strong) PDSTaskRequest *taskRequest;

@property (nonatomic, strong) NSOperationQueue *inspectorQueue;

@property (nonatomic, strong) PDSInspectorDeviceInfo *deviceInfo;

@property (nonatomic, strong) PDSInspectPing *inspectPing;

@property (nonatomic, strong) PDSCustomParameters *customParameters;

@property (nonatomic, strong) PDSInspectorProgressBlock progressBlock;

@property (nonatomic, strong) PDSInspectorCompletedBlock completeBlock;

@end

@implementation PDSSystemInspector

+ (instancetype)sharedInstance{
    static PDSSystemInspector *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[PDSSystemInspector alloc] init];
    });
    return tool;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.isRunning = NO;
        self.inspectorQueue = [[NSOperationQueue alloc] init];
        self.inspectorQueue.name = @"com.inspector.network";
        self.inspectorQueue.maxConcurrentOperationCount = 1;
        self.deviceInfo = [[PDSInspectorDeviceInfo alloc] init];
        self.inspectPing = [[PDSInspectPing alloc] init];
        self.result = [[PDSInspectResult alloc] init];
        self.taskRequest = [[PDSTaskRequest alloc] init];
    }
    return self;
}

- (void)startCustomParameters:(PDSCustomParameters *)customParameters progress:(PDSInspectorProgressBlock)progressBlock complete:(PDSInspectorCompletedBlock)completeBlock {
    if (self.isRunning) {
        return;
    }
    self.isRunning = YES;
    self.customParameters = customParameters;
    self.progressBlock = progressBlock;
    self.completeBlock = completeBlock;

    //2.收集信息
    [self testNetInfo];
    
    //3.ping操作
    [self testPingOperation];
    
    //4.dns操作
    [self testDnsOperation];
    
    //5.访问baidu
    [self testGetBaiduNetWork];
    
    //6.访问app用到的domain是否正常
    [self testGetAppDomain];
    
    //7.测试上传下载速度
    [self testUploadSpeed];
    [self testDownloadSpeed];
    
    [self cleanFile];
}

- (void)restart {
    
    [self stop];
        
    [self startCustomParameters:self.customParameters progress:self.progressBlock complete:self.completeBlock];
}

- (void)stop {
    [self.inspectorQueue cancelAllOperations];
    [self.inspectPing cancelPing];
    [self.taskRequest cancel];
    self.result = [[PDSInspectResult alloc] init];
    self.isRunning = NO;
}

- (void)testNetInfo {
    //获取当前设备info
    if (self.deviceInfo.netWorkType == PDSNetworkTypeNone) {
        //2.判断当前是否有网
        PDSInspectResult *result = [[PDSInspectResult alloc] initWithContent:self.deviceInfo.description success:NO errorMessage:PDSNetErrorNoneKey context:nil];
        [self.result addResult:result];
        [self stop];
        if (self.completeBlock) {
            self.completeBlock(self.result, NO);
        }
        return;
    } else {
        //1.获取当前设备信息成功
        [self progressHandlerTaskType:PDSInspectTaskTypeInfo status:PDSInspectTaskStatusEnd];
        PDSInspectResult *result = [[PDSInspectResult alloc] initWithContent:self.deviceInfo.description success:YES errorMessage:nil context:nil];
        [self.result addResult:result];
    }
}

- (void)testPingOperation {
    
    @weakify(self);
    [self.inspectorQueue addOperationWithBlock:^{
        @strongify(self);
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        @weakify(self);
        [self.inspectPing startPingHostName:self.customParameters.pingAddress response:^(NSString * _Nullable des, BOOL timeout) {
            
        } finish:^(PDSInspectResult * _Nonnull result) {
            @strongify(self);
            PDSDispatch_Main(^{
                [self progressHandlerTaskType:PDSInspectTaskTypePing status:PDSInspectTaskStatusEnd];
            });
            [self.result addResult:result];
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
}

- (void)testDnsOperation {

    @weakify(self);
    [self.inspectorQueue addOperationWithBlock:^{
        @strongify(self);
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [PDSInspectDNS getDNSsWithHostName:self.customParameters.dnsAddress isIPV6:YES completeBlock:^(PDSInspectResult * _Nonnull result) {
            [NSThread sleepForTimeInterval:1.0f];
            PDSDispatch_Main(^{
                [self progressHandlerTaskType:PDSInspectTaskTypeDNS status:PDSInspectTaskStatusEnd];
            });
            [self.result addResult:result];
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
}

- (void)testGetBaiduNetWork {

    @weakify(self);
    [self.inspectorQueue addOperationWithBlock:^{
        @strongify(self);
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [PDSNetworkRequest requestBaiduAddressBlock:^(PDSInspectResult *result) {
            [NSThread sleepForTimeInterval:1.0f];
            PDSDispatch_Main(^{
                [self progressHandlerTaskType:PDSInspectTaskTypeBaidu status:PDSInspectTaskStatusEnd];
            });
            [self.result addResult:result];
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
}

- (void)testGetAppDomain {
    
    @weakify(self);
    [self.inspectorQueue addOperationWithBlock:^{
        @strongify(self);
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [PDSNetworkRequest postRequestMyDomainAddress:self.customParameters.myDomainAddress resonseBlock:^(PDSInspectResult *result) {
            [NSThread sleepForTimeInterval:1.0f];
            PDSDispatch_Main(^{
                [self progressHandlerTaskType:PDSInspectTaskTypeMyDomain status:PDSInspectTaskStatusEnd];
            });
            [self.result addResult:result];
            dispatch_semaphore_signal(sem);
        }];
        ///代码
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
}

- (void)testUploadSpeed {
    
    @weakify(self);
    [self.inspectorQueue addOperationWithBlock:^{
        @strongify(self);
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [self.taskRequest requestUploadCustomParameters:self.customParameters progressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            
        } resonseBlock:^(PDSInspectResult * _Nonnull result) {
            PDSDispatch_Main(^{
                [self progressHandlerTaskType:PDSInspectTaskTypeUpload status:PDSInspectTaskStatusEnd];
            });
            [self.result addResult:result];
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
}

- (void)testDownloadSpeed {

    @weakify(self);
    [self.inspectorQueue addOperationWithBlock:^{
        @strongify(self);
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        @weakify(self);
        [self.taskRequest requestDownloadCustomParameters:self.customParameters progressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            
        } resonseBlock:^(PDSInspectResult * _Nonnull result) {
            @strongify(self);
            PDSDispatch_Main(^{
                [self progressHandlerTaskType:PDSInspectTaskTypeDownload status:PDSInspectTaskStatusEnd];
            });
            [self.result addResult:result];
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
}

- (void)cleanFile {
    @weakify(self);
    [self.inspectorQueue addOperationWithBlock:^{
        @strongify(self);
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        @weakify(self);
        [self.taskRequest requestDeleteFileCustomParameters:self.customParameters resonseBlock:^(BOOL success) {
            @strongify(self);
            self.result.success = success;
            if (self.completeBlock) {
                PDSDispatch_Main(^{
                    self.completeBlock(self.result, YES);
                });
            }
            self.isRunning = NO;
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
}

- (void)progressHandlerTaskType:(PDSInspectTaskType)taskType status:(PDSInspectTaskStatus)status {
    if (self.isRunning == NO) return;
    if (self.progressBlock) {
        self.progressBlock(taskType, status);
    }
}

@end
