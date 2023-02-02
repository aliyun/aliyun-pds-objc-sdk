//
//  PDSAPIRecyclebinFileRequest.m
//  PDS_SDK
//
//  Created by issuser on 2022/12/23.
//

#import "PDSAPIRecyclebinFileRequest.h"
#import "PDSAPIRecyclebinFileResponse.h"

@implementation PDSAPIRecyclebinFileRequest

- (instancetype)initWithDriveID:(NSString *)driveID fileID:(NSString *)fileID {
    self = [super init];
    if (self) {
        self.driveID = driveID;
        self.fileID = fileID;
    }

    return self;
}

- (NSString *)endPoint {
    return @"/recyclebin/trash";
}

- (Class <PDSSerializable>)responseClass {
    return [PDSAPIRecyclebinFileResponse class];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
            @"driveID": @"drive_id",
            @"fileID": @"file_id"
    };
}

@end
