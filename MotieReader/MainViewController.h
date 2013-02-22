//
//  MainViewController.h
//  MotieReader
//
//  Created by Zian Zhou on 2013-02-21.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface MainViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *mainWebView;

@property (nonatomic, strong) NSString *URL;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end
