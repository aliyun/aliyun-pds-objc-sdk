//
//  PDSDriveSession.m
//  PDS_SDK
//
//  Created by issuser on 2022/5/20.
//

#import "PDSDriveSession.h"
#import "PDSTransportClient.h"

@implementation PDSDriveSession

#pragma mark - File API

- (PDSAPIRequestTask<PDSAPICreateDriveResponse *> *)createDrive:(PDSAPICreateDriveRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIDeleteDriveResponse *> *)deleteDrive:(PDSAPIDeleteDriveRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetDriveResponse *> *)getDrive:(PDSAPIGetDriveRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIGetDefaultDriveResponse *> *)getDefaultDrive:(PDSAPIGetDefaultDriveRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIListDriveResponse *> *)listDrive:(PDSAPIListDriveRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIListMyDrivesResponse *> *)myDrivesDrive:(PDSAPIListMyDrivesRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

- (PDSAPIRequestTask<PDSAPIUpdateDriveResponse *> *)updateDrive:(PDSAPIUpdateDriveRequest *)request {
    return [self.transportClient requestSDAPIRequest:request];
}

@end
