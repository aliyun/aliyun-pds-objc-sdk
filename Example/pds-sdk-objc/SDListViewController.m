//
//  SDListViewController.m
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/26.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "SDListViewController.h"
#import "UIViewController+SDPopover.h"
#import "SDPopViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "SDTargetViewController.h"
#import "SDTableViewCell.h"
#import "SVProgressHUD.h"
#import "PDSTestConfig.h"
#import "SDTool.h"

#define kWidth     self.view.frame.size.width
#define kHeight   self.view.frame.size.height

@import PDS_SDK;

@interface SDListViewController ()<UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) UISearchController *searchVC;

@property(nonatomic,strong) NSMutableArray<PDSAPIGetFileResponse *> *dataArray;

@property(nonatomic,strong) NSMutableArray<PDSAPIGetFileResponse *> *searchArray;

@property(nonatomic, copy) PDSTestConfig *testConfig;

@property(nonatomic,strong) PDSAPIRequestTask<PDSAPIListFileResponse *> *listFileTask;

@property(nonatomic,strong) PDSAPIRequestTask<PDSAPIDeleteFileResponse *> * deleteFileTask;

@property(nonatomic,strong) PDSAPIRequestTask<PDSAPIUpdateFileResponse *> *updateFileTask;

@property(nonatomic,strong) PDSAPIRequestTask<PDSAPICreateFileResponse *> *createFileTask;

@property(nonatomic,strong) PDSAPIRequestTask<PDSAPISearchFileResponse *> *searchTask;

@property(nonatomic, strong) PDSUploadTask *uploadTask;

@property(nonatomic, strong) PDSDownloadTask *downloadTask;

@property(nonatomic, assign) int taskID;

@end

@implementation SDListViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSMutableArray<PDSAPIGetFileResponse *> *)searchArray {
    if (!_searchArray) {
        _searchArray = [[NSMutableArray alloc] init];
    }
    return _searchArray;
}

- (PDSTestConfig *)testConfig {
    if (!_testConfig) {
        _testConfig = [[PDSTestConfig alloc] init];
    }
    return _testConfig;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStylePlain)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 55;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"SDTableViewCell" bundle:nil] forCellReuseIdentifier:@"SDTableViewCell"];
    }
    return _tableView;
}

- (UISearchController *)searchVC {
    if (!_searchVC) {
        _searchVC = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchVC.searchBar.translucent = NO;
        _searchVC.searchBar.placeholder = @"搜素文件";
        _searchVC.searchResultsUpdater = self;
        _searchVC.delegate = self;
        _searchVC.dimsBackgroundDuringPresentation = NO;
        _searchVC.hidesBottomBarWhenPushed = YES;
        _searchVC.searchBar.frame = CGRectMake(0, 0, kWidth, 50);
        _searchVC.searchBar.delegate = self;
    }
    return _searchVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    
    [self setupUI];
}

- (void)setupUI {
    self.title = @"文件列表";
    self.taskID = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.searchVC.searchBar;
}

- (void)setupData {
    
    PDSAPIListFileRequest *request = [[PDSAPIListFileRequest alloc] initWithLimit:50 marker:nil driveID:self.testConfig.driveID shareId:nil order:@"updated_at" fields:@"*" orderDirection:@"DESC" parentFileID:@"root" all:NO];
    self.listFileTask = [[PDSClientManager defaultClient].file listFile:request];
    __weak typeof(self) weakSelf = self;
    [self.listFileTask setResponseBlock:^(PDSAPIListFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
        if (!requestError && result.items.count > 0) {
            weakSelf.dataArray = [result.items mutableCopy];
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchVC.active) {
        return self.searchArray.count;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SDTableViewCell" forIndexPath:indexPath];
    PDSAPIGetFileResponse *model = self.dataArray[indexPath.item];
    cell.titleL.text = model.name;
    cell.contentL.text = [NSString stringWithFormat:@"%@ ",model.updatedAt];
    cell.moreButtton.tag = indexPath.row;
    [cell.moreButtton addTarget:self action:@selector(onTapMoreButton:) forControlEvents:(UIControlEventTouchUpInside)];
    return cell;
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchVC.searchBar text];
    NSLog(@"searchString = %@",searchString);
    if (searchString == nil || searchString.length == 0) return;
    NSString *query = [NSString stringWithFormat:@"name match '%@' and status = 'available'",searchString];
    PDSAPISearchFileRequest *reuqest = [[PDSAPISearchFileRequest alloc] initWithDriveID:self.testConfig.driveID imageThumbnailProcess:@"" imageUrlProcess:@"image/resize,m_lfit,w_256,limit_0/format,jpg|image/format,webp" videoThumbnailProcess:nil limit:50 marker:nil orderBy:@"updated_at DESC,image_time DESC" query:query expireTime:3600];
    self.searchTask = [[PDSClientManager defaultClient].file searchFile:reuqest];
    __weak typeof(self) weakSelf = self;
    [self.searchTask setResponseBlock:^(PDSAPISearchFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
        if (!requestError) {
            weakSelf.searchArray = [result.items copy];
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark --- sender

- (void)onTapMoreButton:(UIButton *)sender {
    
    SDPopViewController *vc = [[SDPopViewController alloc] init];
    PDSAPIGetFileResponse *model = self.dataArray[sender.tag];
    vc.title = model.name;
    vc.model = model;
    __weak typeof(self) weakSelf = self;
    vc.completeHandle = ^(PDSFileOperationType type) {
        [weakSelf operationAction:type index:sender.tag];
    };
    [self sdBottomPresentController:vc presentedHeight:410];
}

- (void)operationAction:(PDSFileOperationType)type index:(NSUInteger)index{
    PDSAPIGetFileResponse *model = self.dataArray[index];
    __weak typeof(self) weakSelf = self;
    if (type == PDSFileOperationCreate) {
        [SDTool alertWithControll:self title:@"创建文件夹名称" message:@"请输入文件夹名称" placeholder:@"请输入" completionBlock:^(NSString * _Nonnull text) {
            PDSAPICreateFileRequest *request = [[PDSAPICreateFileRequest alloc] initWithShareID:nil driveID:weakSelf.testConfig.driveID parentFileID:model.parentFileID fileName:text fileID:nil fileSize:0 hashValue:nil preHashValue:nil sectionSize:4000 sectionCount:0 checkNameMode:nil shareToken:nil type: PDSAPICreateFileTypeFolder];
            weakSelf.createFileTask = [[PDSClientManager defaultClient].file createFile:request];
            __strong typeof(self) strongSelf = weakSelf;
            [weakSelf.createFileTask setResponseBlock:^(PDSAPICreateFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                if (!requestError) {
                    [SVProgressHUD showSuccessWithStatus:@"创建文件成功"];
                    [strongSelf dismissViewControllerAnimated:YES completion:nil];
                    [strongSelf setupData];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"创建文件失败"];
                }
            }];
        }];
        
    } else if (type == PDSFileOperationRename) {
        [SDTool alertWithControll:self title:@"修改名称" message:@"请修改名称" placeholder:@"请输入" completionBlock:^(NSString * _Nonnull text) {
            PDSAPIUpdateFileRequest *request = [[PDSAPIUpdateFileRequest alloc] initWithFileID:model.fileID  driveID:weakSelf.testConfig.driveID name:text desc:@"test" hidden:NO encryptMode:nil starred:NO customIndexKey:nil  labels:nil  userMeta:nil];
            weakSelf.updateFileTask  = [[PDSClientManager defaultClient].file updateFile:request];
            __strong typeof(self) strongSelf = weakSelf;
            [weakSelf.updateFileTask setResponseBlock:^(PDSAPIUpdateFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
                if (result) {
                    [SVProgressHUD showSuccessWithStatus:@"重命名成功"];
                    [strongSelf.dataArray setObject:result atIndexedSubscript:index];
                    [strongSelf.tableView reloadData];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"重命名失败"];
                }
            }];
        }];
        
    } else if (type == PDSFileOperationDelete) {
        PDSAPIDeleteFileRequest *request = [[PDSAPIDeleteFileRequest alloc] initWithDriveID:self.testConfig.driveID fileID:model.fileID permanently: YES];
        self.deleteFileTask = [[PDSClientManager defaultClient].file deleteFile:request];
        [self.deleteFileTask setResponseBlock:^(PDSAPIDeleteFileResponse * _Nullable result, PDSRequestError * _Nullable requestError) {
            if (!requestError && result.driveID.length > 0) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                [weakSelf.dataArray removeObject:model];
                [weakSelf.tableView reloadData];
            } else {
                [SVProgressHUD showErrorWithStatus:@"删除失败"];
            }
        }];
    } else if (type == PDSFileOperationMove || type == PDSFileOperationCopy) {
        SDTargetViewController *vc = [[SDTargetViewController alloc] init];
        vc.model = model;
        vc.type = type;
        vc.moveHandle = ^{
            [weakSelf.dataArray removeObject:model];
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == PDSFileOperationUpload) {
        TZImagePickerController *vc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
        [vc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            [weakSelf upload:assets.firstObject model:model];
        }];
        [self presentViewController:vc animated:YES completion:nil];
    } else if (type == PDSFileOperationDownload) {
        [self downloadFile:model];
    }
}

- (void)upload:(PHAsset *)asset model:(PDSAPIGetFileResponse *)model {
    NSString *fileName =  [asset valueForKey:@"filename"];
    NSString *localIdentifier = asset.localIdentifier;
    self.taskID ++;
    PDSUploadPhotoRequest *request = [[PDSUploadPhotoRequest alloc] initWithLocalIdentifier:localIdentifier parentFileID:model.fileID driveID:self.testConfig.driveID shareID:nil fileName:fileName checkNameMode:nil shareToken:nil sharePassword:nil];
    self.uploadTask = [[PDSClientManager defaultClient].file uploadPhotoAsset:request taskIdentifier:[NSString stringWithFormat:@"%d",self.taskID]];
    [SVProgressHUD show];
    [self.uploadTask setResponseBlock:^(PDSFileMetadata * _Nullable result, PDSRequestError * _Nullable requestError, NSString * _Nonnull taskIdentifier) {
        [SVProgressHUD dismiss];
        if (!requestError) {
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"上传失败"];
        }
    }];
    [self.uploadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        float progesss = totalBytesWritten / totalBytesExpectedToWrite;
        [SVProgressHUD showProgress:progesss status:@"正在上传中"];
    }];
}

- (void)downloadFile:(PDSAPIGetFileResponse *)model {
    self.taskID ++;
    NSString *filePath = [NSString stringWithFormat:@"Documents/downloads/%@",model.name];
    filePath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    PDSDownloadUrlRequest *request = [[PDSDownloadUrlRequest alloc] initWithDownloadUrl:model.downloadUrl
                                                                            destination:filePath fileSize:model.size
                                                                                 fileID:model.fileID
                                                                              hashValue:model.hashValue
                                                                               hashType:PDSFileHashTypeCrc64
                                                                                driveID:self.testConfig.driveID
                                                                                shareID:nil shareToken:nil
                                                                             revisionId:nil sharePassword:nil];
    self.downloadTask = [[PDSClientManager defaultClient].file downloadUrl:request taskIdentifier:[NSString stringWithFormat:@"%d",self.taskID]];
    [SVProgressHUD show];
    [self.downloadTask setResponseBlock:^(PDSFileMetadata * _Nullable result, PDSRequestError * _Nullable requestError, NSString * _Nonnull taskIdentifier) {
        [SVProgressHUD dismiss];
        if (!requestError) {
            [SVProgressHUD showSuccessWithStatus:@"下载成功"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"下载失败"];
        }
    }];
    [self.downloadTask setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        float progesss = totalBytesWritten / totalBytesExpectedToWrite;
        [SVProgressHUD showProgress:progesss status:@"正在下载中"];
    }];
}


@end
