//
//  PDSNetDetectionSDKHeader.h
//  Pods
//
//  Created by issuser on 2022/11/24.
//

#ifndef PDSNetDetectionSDKHeader_h
#define PDSNetDetectionSDKHeader_h


typedef enum {
    PDSNetWorkTypeNone = 0,//未连接网络
    PDSNetWorkType2G = 1,
    PDSNetWorkType3G = 2,
    PDSNetWorkType4G = 3,
    PDSNetWorkType5G = 4,
    PDSNetWorkTypeWIFI = 5,
    PDSNetWorkTypeUNKNOWN = 6
}  PDSNetWorkType;


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
    PDSInspectTaskTypeMydomain,
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
