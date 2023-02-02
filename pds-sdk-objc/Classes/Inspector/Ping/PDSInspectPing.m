//
//  PDSNetPingService.m
//  PDSNetDetectionSDK
//
//  Created by issuser on 2022/11/23.
//

#import "PDSInspectPing.h"
#import "PDSSimplePing.h"
#import "PDSConstants.h"
#import "PDSInspectHeader.h"
#import "PDSInspectTool.h"


@interface PDSInspectPing ()<SimplePingDelegate>

@property (nonatomic, copy) NSString *hostName;

@property (nonatomic,assign) NSInteger pingCount;

@property (nonatomic, strong) PDSSimplePing *simplePing;

@property (nonatomic) NSTimeInterval startTime;

@property (nonatomic, strong) NSTimer *pingTimer;

@property (nonatomic, assign) NSUInteger delay;

@property (nonatomic, assign) double packetLoss;

@property (nonatomic) NSUInteger sendPackets;

@property (nonatomic) NSUInteger receivePackets;

@property (nonatomic, strong) PDSReceivePingResponseBlock receivePingHandler;

@property (nonatomic, strong) PDSPDSPingServiceFinishBlock finishHandler;

@end

@implementation PDSInspectPing

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pingCount = 1;
    }
    return self;
}

- (void)startPingHostName:(NSString *)hostName response:(PDSReceivePingResponseBlock)pingResponse finish:(PDSPDSPingServiceFinishBlock)finishBlock {
    
    if (PDSDetectionIsEmpty(hostName)) {
        PDSInspectResult *result = [self createResultSuccess:NO errorMessage:@"Null Host"];
        self.finishHandler(result);
        NSException *exception = [NSException exceptionWithName:@"Null Host" reason:@"Host is Null" userInfo:nil];
        @throw exception;
    } else {
        self.simplePing = [[PDSSimplePing alloc] initWithHostName:hostName];
        self.simplePing.addressStyle = SimplePingAddressStyleAny;
        self.simplePing.delegate = self;
        self.hostName = hostName;
        self.receivePingHandler = pingResponse;
        self.finishHandler = finishBlock;
        self.sendPackets = 0;
        self.receivePackets = 0;
        self.pingTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(doPing) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.pingTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
        [self.simplePing start];
    }
}

- (void)doPing {
    
    if (_sendPackets >= self.pingCount) {
        if (self.finishHandler) {
            PDSInspectResult *result = [self createResultSuccess:YES errorMessage:nil];
            self.finishHandler(result);
        }
        [self stopPing];
        return;
    }
    if (PDSDetectionIsEmpty(self.hostName)) {
        PDSInspectResult *result = [self createResultSuccess:NO errorMessage:@"The ping address is empty"];
        self.finishHandler(result);
        return;
    }
    [self.simplePing start];
}

- (void)stopPing {
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    self.delay = 0;
    self.packetLoss = 0;
}

- (void)cancelPing {
    [self.simplePing stop];
}

#pragma MARK --- SimplePingDelegate
- (void)simplePing:(PDSSimplePing *)pinger didStartWithAddress:(NSData *)address{
    
    [pinger sendPingWithData:nil];
    //提前获取地址
//    self.hostName = [PDSDetectionTool convertStringForAddressData:address];
}
    
- (void)simplePing:(PDSSimplePing *)pinger didFailWithError:(NSError *)error {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(simplePingFail) object:nil];
    [self.simplePing stop];
}

- (void)simplePing:(PDSSimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    
    self.sendPackets ++;
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)simplePing:(PDSSimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self.simplePing stop];
}

- (void)simplePing:(PDSSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self.simplePing stop];
    self.receivePackets++;
    self.delay = ([NSDate timeIntervalSinceReferenceDate] - self.startTime) * 1000;
    self.packetLoss = (double)((self.sendPackets - self.receivePackets) * 1.f / self.sendPackets * 100);
        
    NSString *des = [NSString stringWithFormat:@"seq:%ld, delay:%ld, packetloss:%f",self.sendPackets ,self.delay, self.packetLoss];

    if (self.receivePingHandler) {
        self.receivePingHandler(des, NO);
    }
}

- (void)pingTimeout {
 
    [self.simplePing stop];

    PDSInspectResult *reslut = [self createResultSuccess:NO errorMessage:@"Network ping timeout"];
    self.finishHandler(reslut);
}

- (void)simplePing:(PDSSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    
    [self.simplePing stop];
    [self simplePingFail];
}

- (void)simplePingFail {
    PDSInspectResult *reslut = [self createResultSuccess:NO errorMessage:@"Ping fail"];
    self.finishHandler(reslut);
}

- (PDSInspectResult *)createResultSuccess:(BOOL)success errorMessage:(NSString *)errorMessage {
    PDSInspectResult *result = [[PDSInspectResult alloc] initWithContent:nil success:success errorMessage:errorMessage context:nil];
    return result;
}

@end
