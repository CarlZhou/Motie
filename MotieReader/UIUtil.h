//
//  UIUtil.h
//  MotieReader
//
//  Created by Carl on 2013-02-20.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIUtil : NSObject

@property BOOL isNetWorkAvailable;

+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

// Shared Instance
+ (UIUtil *)sharedInstance;

@end
