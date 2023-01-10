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

#import "PDSAPIRequestTask.h"
#import "PDSRequestError.h"
#import "PDSTransportClient.h"
#import "PDSInternalTypes.h"
#import "PDSAPIRequest.h"
#import "PDSAPIResponse.h"
#import "PDSTransportClient+Internal.h"
#import "PDSTask+Internal.h"
#import "PDSError.h"


@implementation PDSAPIRequestTask {

}

- (PDSAPIRequestTask *)setResponseBlock:(PDSAPIResponseBlock)responseBlock {
#pragma unused(responseBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (PDSAPIRequestTask *)setResponseBlock:(PDSAPIResponseBlockImpl)responseBlock queue:(NSOperationQueue *)queue {
#pragma unused(responseBlock)
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                     userInfo:nil];
}

- (PDSAPIResponseBlockStorage)storageBlockWithResponseBlock:(PDSAPIResponseBlockImpl)responseBlock {
    __weak PDSAPIRequestTask *weakSelf = self;
    PDSAPIResponseBlockStorage storageBlock = ^BOOL(NSData *data, NSURLResponse *response, NSError *clientError) {
        PDSAPIRequestTask *strongSelf = weakSelf;
        if (strongSelf == nil) {
            return NO;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        int statusCode = (int) httpResponse.statusCode;
        NSDictionary *httpHeaders = httpResponse.allHeaderFields;

        PDSAPIRequest *request = self.request;

        BOOL successful = NO;

        id result = nil;
        PDSRequestError *requestError = [PDSTransportClient requestErrorWithErrorData:data
                                                                          clientError:clientError
                                                                           statusCode:statusCode
                                                                          httpHeaders:httpHeaders];
        //错误分为两种情况，客户端/服务端异常,业务层自身错误
        if (!requestError) {
            NSError *serializationError = nil;
            result = [PDSTransportClient resultWithRequest:request data:data serializationError:&serializationError];
            if (serializationError) {//JSON解析错误
                requestError = [[PDSRequestError alloc] initWithErrorType:PDSRequestErrorTypeUnknown
                                                               statusCode:statusCode
                                                                errorCode:PDSErrorCodeCommonFormatInvalid
                                                             errorMessage:PDSErrorCodeCommonFormatInvalidMessage
                                                              clientError:nil];
            } else {
                result = request.responseClass ? result : nil;
                if ([result isKindOfClass:[PDSAPIResponse class]]) {
                    requestError = ((PDSAPIResponse *) result).error;
                }
                if (!requestError) {//没有错误
                    successful = YES;
                }
            }
        }

        responseBlock(result, requestError);
        return successful;
    };

    return storageBlock;
}

@end