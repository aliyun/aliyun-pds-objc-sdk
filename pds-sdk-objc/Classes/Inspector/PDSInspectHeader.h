//
//  PDSNetDetectionSDKHeader.h
//  Pods
//
//  Created by issuser on 2022/11/24.
//

#ifndef PDSNetDetectionSDKHeader_h
#define PDSNetDetectionSDKHeader_h


typedef enum {
    PDSNetworkTypeNone = 0,//未连接网络
    PDSNetworkType2G = 1,
    PDSNetworkType3G = 2,
    PDSNetworkType4G = 3,
    PDSNetworkType5G = 4,
    PDSNetworkTypeWIFI = 5,
    PDSNetworkTypeUnknown = 6
}  PDSNetworkType;


typedef NS_ENUM(NSInteger, PDSNetErrorType) {
    PDSNetErrorTypeNone,
    PDSNetErrorTypePingFail,
    PDSNetErrorTypePingTimeOut,
    PDSNetErrorTypeDNSFail,
    PDSNetErrorTypePoor,
    PDSNetErrorTypeFail,
    PDSNetErrorTypeUnknown,
};


typedef NS_ENUM(NSInteger, PDSInspectTaskType) {
    PDSInspectTaskTypeInfo = 0,
    PDSInspectTaskTypePing,
    PDSInspectTaskTypeDNS,
    PDSInspectTaskTypeBaidu,
    PDSInspectTaskTypeMyDomain,
    PDSInspectTaskTypeUpload,
    PDSInspectTaskTypeDownload
};

typedef enum{
    PDSInspectTaskStatusStart,
    PDSInspectTaskStatusIng,
    PDSInspectTaskStatusEnd
}  PDSInspectTaskStatus;


static inline BOOL PDSDetectionIsEmpty(id thing) {
    return thing == nil
            || ([thing respondsToSelector:@selector(length)]
            && [(NSData *) thing length] == 0)
            || ([thing respondsToSelector:@selector(count)]
            && [(NSArray *) thing count] == 0);
};


#endif /* PDSNetDetectionSDKHeader_h */
