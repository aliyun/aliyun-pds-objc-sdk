//
//  PDSFileInfo.m
//  PDS_SDK
//
//  Created by issuser on 2022/12/13.
//

#import "PDSCustomParameters.h"

@implementation PDSCustomParameters

- (instancetype)init {
    self = [super init];
    if (self) {
        self.accessToken = @"";
        self.driveId = @"";
        self.pingAddress = @"www.baidu.com";
        self.dnsAddress = @"www.taobao.com";
        self.myDomainAddress = @"https://terms.aliyun.com/legal-agreement/terms/suit_bu1_ali_cloud/suit_bu1_ali_cloud201802111644_32057.html?";
//        self.downloadUrl = @"https://dldir1.qq.com/weixin/mac/WeChatMac.dmg";
        NSURL *documentUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        documentUrl = [documentUrl URLByAppendingPathComponent:@"download/WeChatMac.dmg"];
    }
    return self;
}

@end
