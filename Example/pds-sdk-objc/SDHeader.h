//
//  SDHeader.h
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/30.
//  Copyright © 2022 turygo. All rights reserved.
//

#ifndef SDHeader_h
#define SDHeader_h

typedef NS_ENUM(NSInteger, PDSFileOperationType) {
    PDSFileOperationMove,
    PDSFileOperationCopy,
    PDSFileOperationCreate,
    PDSFileOperationRename,
    PDSFileOperationDelete,
    PDSFileOperationUpload,
    PDSFileOperationDownload,
};

typedef void(^SDCompleteHandle)(PDSFileOperationType type);

typedef void(^SDMoveHandle)(void);



#endif /* SDHeader_h */
