//
//  LibraryController.h
//  MotieReader
//
//  Created by Carl on 2013-02-19.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "LibraryViewCellBtn.h"
#import "iToast.h"
#import "PullToRefreshView.h"
#import "MBProgressHUD.h"

@class ChapterViewController;

#import <CoreData/CoreData.h>

@interface LibraryController : UITableViewController <NSFetchedResultsControllerDelegate, LibraryViewCellBtnDelegate, PullToRefreshViewDelegate>

@property (strong, nonatomic) ChapterViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *LibraryURL;
@property (strong, nonatomic) NSMutableArray *libraryBooks;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

- (void)loadLibrary;
@end
