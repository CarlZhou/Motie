//
//  DetailViewController.h
//  MotieReader
//
//  Created by Carl on 2013-02-19.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "iToast.h"
#import <Parse/Parse.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) UIWebView *detailedWebView;

@property (strong, nonatomic) NSMutableArray *objects;

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) NSString *nextURL, *prevURL, *curURL;

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UILabel *chapterInfo;
@property (strong, nonatomic) UIButton *chapterInfoBtn;
@property (strong, nonatomic) NSString *curChapterContent;


@property BOOL isFullScreen, isChapterAvaliableOffline, isChapterFetchedFromServer;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
