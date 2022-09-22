//
//  SDTargetViewController.m
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/30.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "SDTargetViewController.h"
#import "SDTableViewCell.h"
#import "PDSTestConfig.h"
#import "SVProgressHUD.h"

@import PDS_SDK;

@interface SDTargetViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic, copy) PDSTestConfig *testConfig;

@property(nonatomic, strong) PDSAPIRequestTask<PDSAPIListFileResponse *> *listFileTask;

@property(nonatomic, strong) PDSAPIRequestTask<PDSAPIMoveFileResponse *> *task1;

@property(nonatomic, strong) PDSAPIRequestTask<PDSAPICopyFileResponse *> *task2;

@end

@implementation SDTargetViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStylePlain)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"SDTableViewCell" bundle:nil] forCellReuseIdentifier:@"SDTableViewCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (PDSTestConfig *)testConfig {
    if (!_testConfig) {
        _testConfig = [[PDSTestConfig alloc] init];
    }
    return _testConfig;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupData];
    [self setupUI];
}

- (void)setupUI {
    self.title = @"个人空间";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    NSLog(@"file id = %@",self.model.fileID);
    PDSAPIListFileRequest *request = [[PDSAPIListFileRequest alloc] initWithLimit:50 marker:nil driveID:self.testConfig.driveID shareId:nil order:nil fields:@"*" orderDirection:@"" parentFileID:@"root" all:NO];
    self.listFileTask = [[PDSClientManager defaultClient].file listFile:request];
    __weak typeof(self) weakSelf = self;
    [self.listFileTask setResponseBlock:^(PDSAPIListFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
        if (!requestError && result.items.count > 0) {
            for (PDSAPIGetFileResponse *model in result.items) {
                if (![weakSelf.model.fileID isEqualToString:model.fileID] && [model.type isEqualToString:@"folder"]) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SDTableViewCell" forIndexPath:indexPath];
    PDSAPIGetFileResponse *model = self.dataArray[indexPath.item];
    cell.titleL.text = [NSString stringWithFormat:@"%@",model.name];
    cell.contentL.text = [NSString stringWithFormat:@"%@",model.updatedAt];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PDSAPIGetFileResponse *model = self.dataArray[indexPath.item];
    [self moveAction:model];
}

- (void)moveAction:(PDSAPIGetFileResponse *)model{
    
    __weak typeof(self) weakSelf = self;
    if (self.type == PDSFileOperationMove) {
        PDSAPIMoveFileRequest *request = [[PDSAPIMoveFileRequest alloc] initWithDriveID:self.testConfig.driveID fileID:self.model.fileID toParentFileID:model.fileID newName:self.model.name overwrite:NO];
        self.task1 = [[PDSClientManager defaultClient].file moveFile:request];
        [self.task1 setResponseBlock:^(PDSAPIMoveFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
            if (!requestError) {
                [SVProgressHUD showSuccessWithStatus:@"移动成功"];
                if (weakSelf.moveHandle) {
                    weakSelf.moveHandle();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                [SVProgressHUD showErrorWithStatus:@"移动失败"];
            }
        }];
    } else {
        PDSAPICopyFileRequest *request = [[PDSAPICopyFileRequest alloc] initWithFileID:self.model.fileID driveID:self.testConfig.driveID toParentFileID:model.fileID toDriveID:self.testConfig.driveID autoRename:YES newName:self.model.name];
        self.task2 = [[PDSClientManager defaultClient].file copyFile:request];
        [self.task2 setResponseBlock:^(PDSAPICopyFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
            if (!requestError) {
                [SVProgressHUD showSuccessWithStatus:@"复制成功"];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                [SVProgressHUD showErrorWithStatus:@"复制失败"];
            }
        }];
    }
}

@end
