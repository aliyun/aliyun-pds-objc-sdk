//
//  PDSNetDetectionResult.m
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/24.
//

#import "PDSInspectResult.h"

@interface PDSInspectResult ()

@property (nonatomic, strong) NSMutableArray<PDSInspectResult *> *mutabResults;

@end

@implementation PDSInspectResult


- (instancetype)initWithContent:(NSString * _Nullable)content success:(BOOL)success errorMessage:(NSString * _Nullable)errorMessage context:(NSString * _Nullable)context {
    self = [super init];
    if (self) {
        self.context = context;
        self.success = success;
        self.errorMessage = errorMessage;
        self.context = context;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.success = NO;
        self.context = @"";
        self.errorMessage = @"";
        self.context = @"";
        self.mutabResults = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addResult:(PDSInspectResult *)result {
    [self.mutabResults addObject:result];
    self.results = [NSArray arrayWithArray:self.mutabResults];
}

@end
