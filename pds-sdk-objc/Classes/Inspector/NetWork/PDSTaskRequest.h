//
//  PDSUploadTaskRequest.h
//  PDSSystemInspector
//
//  Created by issuser on 2022/12/18.
//

#import <Foundation/Foundation.h>
#import "PDSCustomParameters.h"
#import "PDSInspectResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^PDSFileProgressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

typedef void (^PDSFileCompleteBlock)(PDSInspectResult *result);

@interface PDSTaskRequest : NSObject

- (void)requestUploadCustomParameters:(PDSCustomParameters *)customParameters progressBlock:(PDSFileProgressBlock)progressBlock resonseBlock:(void (^)(PDSInspectResult *result))block;

- (void)requestDownloadCustomParameters:(PDSCustomParameters *)customParameters progressBlock:(PDSFileProgressBlock)progressBlock resonseBlock:(PDSFileCompleteBlock)block;

- (void)requestDeleteFileCustomParameters:(PDSCustomParameters *)customParameters resonseBlock:(void(^)(BOOL))block;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
