//
//  PDSNetWorkRequest.m
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#define BAIDU_ADDRESS  @"https://www.baidu.com"

#import "PDSNetWorkRequest.h"
#import <extobjc/EXTobjc.h>
#import "PDSConstants.h"

@interface PDSNetWorkRequest ()

@end

@implementation PDSNetWorkRequest

+ (instancetype)sharedInstance{
    static PDSNetWorkRequest *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[PDSNetWorkRequest alloc] init];
    });
    return tool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)requestBaiduAddressBlock:(void (^)(PDSInspectResult *result))block {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",BAIDU_ADDRESS]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
        PDSInspectResult *result = [[PDSInspectResult alloc] init];
        if (error == nil && 200 == [(NSHTTPURLResponse *)response statusCode]) {
            result.success = YES;
            block(result);
        } else {
            result.success = NO;
            result.errorMessage = error.description;
            block(result);
        }
    }];
    [dataTask resume];
}


+ (void)postRequestMyDomainAddress:(NSString *)address resonseBlock:(void (^)(PDSInspectResult *result))block {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",address]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url] ;
//    request.HTTPMethod = @"POST";
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    //参数需要拼接
//    request.HTTPBody = [[NSString stringWithFormat:@""] dataUsingEncoding:NSUTF8StringEncoding];
//    //请求头参数
//    [request setValue:@"" forHTTPHeaderField:@""];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        PDSInspectResult *result = [[PDSInspectResult alloc] init];
        if (error == nil && 200 == [(NSHTTPURLResponse *)response statusCode]) {
            result.success = YES;
            block(result);
        } else {
            result.success = NO;
            result.errorMessage = error.description;
            block(result);
        }
    }];
    
    [dataTask resume];
}

@end
