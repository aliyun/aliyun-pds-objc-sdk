//
//  PDSDriveSession.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/20.
//

#import <PDS_SDK/PDSAPIRequestTask.h>
#import <PDS_SDK/PDSBaseSession.h>

#import "PDSAPICreateDriveRequest.h"
#import "PDSAPIDeleteDriveRequest.h"
#import "PDSAPIGetDriveRequest.h"
#import "PDSAPIGetDefaultDriveRequest.h"
#import "PDSAPIListDriveRequest.h"
#import "PDSAPIListMyDrivesRequest.h"
#import "PDSAPIUpdateDriveRequest.h"

#import "PDSAPICreateDriveResponse.h"
#import "PDSAPIDeleteDriveResponse.h"
#import "PDSAPIGetDriveResponse.h"
#import "PDSAPIGetDefaultDriveResponse.h"
#import "PDSAPIListDriveResponse.h"
#import "PDSAPIListMyDrivesResponse.h"
#import "PDSAPIUpdateDriveResponse.h"


NS_ASSUME_NONNULL_BEGIN

@interface PDSDriveSession : PDSBaseSession

/// 创建磁盘接口
/// https://help.aliyun.com/document_detail/175927.html#h2--drive5
/// @param request 创建磁盘接口请求
- (PDSAPIRequestTask<PDSAPICreateDriveResponse *> *)createDrive:(PDSAPICreateDriveRequest *)request;

/// 删除磁盘接口
/// https://help.aliyun.com/document_detail/175927.html#h2--drive6
/// @param request 删除磁盘接口请求
- (PDSAPIRequestTask<PDSAPIDeleteDriveResponse *> *)deleteDrive:(PDSAPIDeleteDriveRequest *)request;

/// 获取磁盘详细信息
/// https://help.aliyun.com/document_detail/175927.html#h2--drive-7
/// @param request 获取磁盘详细信息接口请求
- (PDSAPIRequestTask<PDSAPIGetDriveResponse *> *)getDrive:(PDSAPIGetDriveRequest *)request;

/// 获取默认磁盘信息
/// https://help.aliyun.com/document_detail/175927.html#h2--drive-8
/// @param request 获取默认磁盘信息接口请求
- (PDSAPIRequestTask<PDSAPIGetDefaultDriveResponse *> *)getDefaultDrive:(PDSAPIGetDefaultDriveRequest *)request;

/// 列举指定用户磁盘
/// https://help.aliyun.com/document_detail/175927.html#h2--drive9
/// @param request 列举指定用户磁盘接口请求
- (PDSAPIRequestTask<PDSAPIListDriveResponse *> *)listDrive:(PDSAPIListDriveRequest *)request;

/// 列举当前用户的磁盘
/// https://help.aliyun.com/document_detail/175927.html#h2--drive10
/// @param request 列举当前用户的磁盘接口请求
- (PDSAPIRequestTask<PDSAPIListMyDrivesResponse *> *)myDrivesDrive:(PDSAPIListMyDrivesRequest *)request;

/// 更新磁盘信息
/// https://help.aliyun.com/document_detail/175927.html#h2--drive-11
/// @param request 更新磁盘信息接口请求
- (PDSAPIRequestTask<PDSAPIUpdateDriveResponse *> *)updateDrive:(PDSAPIUpdateDriveRequest *)request;

@end

NS_ASSUME_NONNULL_END
