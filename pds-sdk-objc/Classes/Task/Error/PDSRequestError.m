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

#import "PDSRequestError.h"
#import "PDSError.h"


@implementation PDSRequestError {

}

+ (id)invalidResponseError {
    return [[PDSRequestError alloc] initWithErrorType:PDSRequestErrorTypeUnknown
                                           statusCode:200
                                            errorCode:PDSErrorCodeCommonFormatInvalid
                                         errorMessage:PDSErrorCodeCommonFormatInvalidMessage
                                          clientError:nil];
}


- (id)initWithErrorType:(PDSRequestErrorType)errorType statusCode:(NSInteger)statusCode errorCode:(NSString *)errorCode errorMessage:(NSString *)errorMessage clientError:(NSError *)clientError {
    self = [self init];
    if (self) {
        self.type = errorType;
        self.statusCode = statusCode;
        self.code = errorCode;
        self.message = errorMessage;
        self.clientError = clientError;
    }
    return self;
}


- (id)initAsClientError:(NSError *)error {
    return [self initWithErrorType:PDSRequestErrorTypeClient statusCode:error.code errorCode:nil errorMessage:error.localizedDescription clientError:error];
}

- (NSString *)description {
    if(self.clientError) {
        return [NSString stringWithFormat:@"transportClient Error: %@",[self.clientError description]];
    }
    return [NSString stringWithFormat:@"Server Error: Status Code :%ld,Error Code :%@, Error Message: %@",self.statusCode,self.code,self.message];
}
@end
