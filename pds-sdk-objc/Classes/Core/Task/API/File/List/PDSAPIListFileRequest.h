//
//  PDSAPIListFileRequest.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/26.
//

#import <PDS_SDK/PDSAPIRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIListFileRequest : PDSAPIRequest
//限制数
@property(nonatomic, assign) NSInteger limit;
//
@property(nonatomic, copy) NSString *marker;
///磁盘ID,同分享ID两者必填之一
@property(nonatomic, copy) NSString *driveID;

@property(nonatomic, copy) NSString *shareId;

@property(nonatomic, copy) NSString *order;

@property(nonatomic, copy) NSString *fields;

@property(nonatomic, copy) NSString *orderDirection;
///父文件夹ID,根目录的话传空,必填
@property(nonatomic, copy) NSString *parentFileID;

@property(nonatomic, assign) BOOL all;

- (instancetype)initWithLimit:(NSInteger)limit marker:(NSString * _Nullable)marker driveID:(NSString *)driveID shareId:(NSString * _Nullable)shareId order:(NSString * _Nullable)order fields:(NSString * _Nullable)fields orderDirection:(NSString * _Nullable)orderDirection parentFileID:(NSString *)parentFileID all:(BOOL)all;

@end

NS_ASSUME_NONNULL_END
//
