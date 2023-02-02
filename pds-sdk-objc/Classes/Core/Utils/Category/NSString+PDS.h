//
//  NSString+PDS.h
//  PDS_SDK
//
//  Created by xinjiu on 2021/12/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PDS)
/**
 * 10进制转16进制
 * @param completeLength 补全位数，如果转换以后的长度不足对应的位数，会在最前面补0，如果补全位数为0的话那么不补全位数
 * @return 转换后的16进制字符串
 */
- (NSString *)pds_decimalToHexWithCompleteLength:(NSInteger)completeLength;
@end

NS_ASSUME_NONNULL_END
