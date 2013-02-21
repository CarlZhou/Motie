//
//  UIUtil.m
//  MotieReader
//
//  Created by Carl on 2013-02-20.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import "UIUtil.h"

@implementation UIUtil

+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles:nil];
        [alert show];
    });
}

@end
