//
//  PDSAPIRecyclebinFileRequest.h
//  PDS_SDK
//
//  Created by issuser on 2022/12/23.
//

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIRecyclebinFileRequest : PDSAPIRequest
///存储空间ID
@property(nonatomic, copy) NSString *driveID;
///文件ID
@property(nonatomic, copy) NSString *fileID;

- (instancetype)initWithDriveID:(NSString *)driveID fileID:(NSString *)fileID;

@end

NS_ASSUME_NONNULL_END
