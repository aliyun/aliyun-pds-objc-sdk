//
//  PDSAPIListDriveResponse.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/18.
//

#import <PDS_SDK/PDSAPIResponse.h>
#import "PDSAPIGetDriveResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIListDriveResponse : PDSAPIResponse

@property(nonatomic, copy) NSArray<PDSAPIGetDriveResponse *> *items;

@property(nonatomic, copy) NSString *nextMarker;

@end

NS_ASSUME_NONNULL_END
