//
//  SDTool.m
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/5/30.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "SDTool.h"

@implementation SDTool

+ (void)alertWithControll:(UIViewController*)sourceVC title:(NSString *)title message:(NSString*)message placeholder:(NSString *)placeholder completionBlock:(void(^)(NSString *text))block {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action_0 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alert.textFields.firstObject;
        if (textField.text == nil || textField.text.length == 0) return;
        block(textField.text);
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeholder;
    }];
    [alert addAction:action_0];
    [alert addAction:action_1];
    [sourceVC presentViewController:alert animated:YES completion:nil];
}


@end
