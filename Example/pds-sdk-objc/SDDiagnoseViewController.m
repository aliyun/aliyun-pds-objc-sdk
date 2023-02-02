//
//  SDDiagnoseViewController.m
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/12/10.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "SDDiagnoseViewController.h"
#import "PDSTextView.h"
#import <extobjc/EXTobjc.h>

@import PDS_SDK;

@interface SDDiagnoseViewController ()

@property (nonatomic, strong) PDSTextView *textView;

@end

@implementation SDDiagnoseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
    
    [self setupUI];
    
    PDSCustomParameters *parameters = [[PDSCustomParameters alloc] init];
    
    @weakify(self);
    [[PDSSystemInspector sharedInstance] startCustomParameters:parameters progress:^(PDSInspectTaskType taskType, PDSInspectTaskStatus status) {
        @strongify(self);
        self.textView.text = [NSString stringWithFormat:@"进度：%zd/7\n ",taskType+1];
    } complete:^(PDSInspectResult * _Nonnull result, BOOL finished) {
        @strongify(self);
        self.textView.text = result.description;
    }];
}

- (void)setup {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupUI {
    
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    backBtn.frame = CGRectMake(10, 20, 80, 40);
//    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
    
    self.textView = [[PDSTextView alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) -200)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.editable = NO;
    self.textView.backgroundColor = [UIColor blackColor];
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.textColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
}

@end
