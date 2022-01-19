//
//  NSString+PDS.m
//  PDS_SDK
//
//  Created by xinjiu on 2021/12/15.
//

#import "NSString+PDS.h"

@implementation NSString (PDS)

- (NSString *)pds_decimalToHexWithCompleteLength:(NSInteger)completeLength {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    uint64_t result = 0;
    [scanner scanUnsignedLongLong:&result];
    if (completeLength == 0) {
        return [NSString stringWithFormat:@"%llx", result];
    }
    return [NSString stringWithFormat:[NSString stringWithFormat:@"%%0%dllx",completeLength],result];
}
@end
