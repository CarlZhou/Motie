//
//  LibraryController.h
//  MotieReader
//
//  Created by Carl on 2013-02-19.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class ChapterViewController;

#import <CoreData/CoreData.h>

@interface LibraryController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) ChapterViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *LibraryURL;

- (void)loadTutorials;
@end
