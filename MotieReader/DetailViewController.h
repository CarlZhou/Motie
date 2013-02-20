//
//  DetailViewController.h
//  MotieReader
//
//  Created by Carl on 2013-02-19.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) UIWebView *detailedWebView;

@property (strong, nonatomic) NSMutableArray *objects;

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *prevURL;

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end
