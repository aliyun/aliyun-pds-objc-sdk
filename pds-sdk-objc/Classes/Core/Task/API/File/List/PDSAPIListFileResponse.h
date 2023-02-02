//
//  PDSAPIListFileResponse.h
//  PDS_SDK
//
//  Created by issuser on 2022/5/26.
//

#import <PDS_SDK/PDSAPIResponse.h>
#import "PDSAPIGetFileResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDSAPIListFileResponse : PDSAPIResponse

@property(nonatomic, copy) NSArray<PDSAPIGetFileResponse *> *items;

@property(nonatomic, copy) NSString *nextMarker;

@end

NS_ASSUME_NONNULL_END
