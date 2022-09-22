//
//  SDTableViewCell.h
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/27.
//  Copyright © 2022 turygo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UIButton *moreButtton;

@end

NS_ASSUME_NONNULL_END
