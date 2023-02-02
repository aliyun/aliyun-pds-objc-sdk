//
//  PDSAPIRecyclebinFileResponse.h
//  PDS_SDK
//
//  Created by issuser on 2022/12/23.
//

#import <PDS_SDK/PDSAPIResponse.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIRecyclebinFileResponse : PDSAPIResponse
///
@property(nonatomic, copy) NSString *status;
///文件ID
@property(nonatomic, copy) NSString *fileID;

@end

NS_ASSUME_NONNULL_END
