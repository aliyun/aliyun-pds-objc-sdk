//
//  PDSTextView.m
//  pds-sdk-objc_Example
//
//  Created by issuser on 2022/12/10.
//  Copyright © 2022 turygo. All rights reserved.
//

#import "PDSTextView.h"

@implementation PDSTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor greenColor];
        if ([self respondsToSelector:@selector(layoutManager)]) {
            self.layoutManager.allowsNonContiguousLayout = NO;
        }
        self.font = [UIFont systemFontOfSize:14];
        self.editable = NO;
    }
    return self;
}

- (void)appendText:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    if (self.text.length == 0) {
        self.text = text;
    } else {
        self.text = [NSString stringWithFormat:@"%@\n%@" , self.text, text];
        [self scrollToBottomAnimated:YES];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    [self scrollRangeToVisible:NSMakeRange(self.text.length, 0)];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSString *selectorName = NSStringFromSelector(action);
    return [selectorName hasPrefix:@"copy"] || [selectorName hasPrefix:@"select"];
}


@end
