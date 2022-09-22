//
//  SDPopViewController.m
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/27.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "SDPopViewController.h"
#import "SDTargetViewController.h"

@interface SDPopViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,copy) NSArray *dataArray;

@property(nonatomic, copy) NSArray *titleArray;

@end

@implementation SDPopViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStylePlain)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"item"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    if ([self.model.type isEqualToString:@"folder"]) {
        self.dataArray = @[@"移动", @"复制",@"创建",@"重命名",@"删除",@"上传"];
        self.titleArray = @[@"icon-file-move.png",
                            @"icon_file_copy.png",
                            @"icon-file-folder-add.png",
                            @"icon_filere_name.png",
                            @"icon-file-delete.png",
                            @"icon_enjoy_normal.png"];
    } else {
        self.dataArray = @[@"移动", @"复制",@"创建",@"重命名",@"删除",@"下载"];
        self.titleArray = @[@"icon-file-move.png",
                            @"icon_file_copy.png",
                            @"icon-file-folder-add.png",
                            @"icon_filere_name.png",
                            @"icon-file-delete.png",
                            @"icon-file-download.png"];
    }
}

- (void)setupUI{
    [self.view addSubview:self.tableView];
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, [UIScreen mainScreen].bounds.size.width-40, 30)];
    titleL.text = self.title;
    [headerV addSubview:titleL];
    self.tableView.tableHeaderView = headerV;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.titleArray[indexPath.row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.completeHandle) {
        if ([self.model.type isEqualToString:@"folder"]) {
            self.completeHandle((PDSFileOperationType)indexPath.row);
        } else {
            PDSFileOperationType type = (PDSFileOperationType)indexPath.row;
            self.completeHandle(type == PDSFileOperationUpload ? PDSFileOperationDownload : type);
        }
    }
}

@end
