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

#import "PDSTaskFolderExistValidator.h"
#import "NSError+PDS.h"


@interface PDSTaskFolderExistValidator ()
@property(nonatomic, strong) NSString *folderPath;
@end

@implementation PDSTaskFolderExistValidator {

}
+ (instancetype)validatorWithFolderPath:(NSString *)folderPath {
    PDSTaskFolderExistValidator *validator = [[PDSTaskFolderExistValidator alloc] initWithFolderPath:folderPath];
    return validator;
}

- (instancetype)initWithFolderPath:(NSString *)folderPath {
    self = [self init];
    self.folderPath = folderPath;
    return self;
}


- (BOOL)validateWithError:(NSError **)error {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.folderPath]) {
        return YES;
    }
    NSError *createDirError = nil;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:self.folderPath
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&createDirError];
    if (!result) {
        if(error) {
            *error = [NSError pds_errorWithCode:PDSErrorFileCreatedFailed message:@"文件目录创建失败"];
        }
        return NO;
    }
    return YES;
}
@end
