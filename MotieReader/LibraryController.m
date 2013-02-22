//
//  LibraryController.m
//  MotieReader
//
//  Created by Carl on 2013-02-19.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import "LibraryController.h"

#import "ChapterViewController.h"

#import "TFHpple.h"

#import "UIUtil.h"

@interface LibraryController () {
}
@end

@implementation LibraryController
{
    PullToRefreshView *pull;
    NSArray *updatedLibrary;
}

@synthesize detailViewController = _detailViewController;

- (void)loadLibrary
{
    if (![[UIUtil sharedInstance] isNetWorkAvailable])
    {
        [[[[iToast makeText:NSLocalizedString(@"Network is not avaliable, Please check internet connection.", @"")]
           setGravity:iToastGravityCenter] setDuration:1000] show];
        [pull finishedLoading];
        return;
    }

    [self performSelectorInBackground:@selector(loadLibraryFromServer) withObject:nil];
}

- (void)loadLibraryFromServer
{
    // 1
    NSURL *libraryUrl = [NSURL URLWithString:self.LibraryURL];
    NSData *libraryHtmlData = [NSData dataWithContentsOfURL:libraryUrl];

    // 2
    TFHpple *libraryParser = [TFHpple hppleWithHTMLData:libraryHtmlData];

    // 3
    NSString *libraryXpathQueryString = @"//div[@class='txtbox-item']/a";
    NSArray *libraryNodes = [libraryParser searchWithXPathQuery:libraryXpathQueryString];

    NSMutableArray *libraryBooks = [NSMutableArray array];
    LibraryBook *book;
    NSUInteger count = 0;
    for (TFHppleElement *element in libraryNodes) {
        // New Library Book Method
        switch (count)
        {
            case 0:
            {
                if (book)
                    book = nil;
                book = [[LibraryBook alloc] init];
                [libraryBooks addObject:book];
                book.bookTitle = [[element firstChild] content];
                book.bookURL = [element objectForKey:@"href"];
                count++;
                break;
            }
            case 1:
            {
                book.curReadingURL = [element objectForKey:@"href"];
                count++;
                break;
            }
            default:
            {
                book.latestTitle = [[element firstChild] content];
                book.latestURL = [element objectForKey:@"href"];
                count = 0;
                break;
            }
        }
    }
    updatedLibrary = libraryBooks;
    self.libraryBooks = [updatedLibrary mutableCopy];
    [self.tableView reloadData];
    [pull finishedLoading];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Motie";
    self.libraryBooks = [NSMutableArray array];

    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];

    if ([[UIUtil sharedInstance] isNetWorkAvailable])
        [self loadLibraryFromServer];
    else
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [defaults objectForKey:@"oldLibraryBooks"];
        self.libraryBooks = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIUtil sharedInstance].oldLibraryBooksData = self.libraryBooks;
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section)
    {
        case 0:
            return self.libraryBooks.count;
        default:
            return 0;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    if (indexPath.section == 0)
    {
        LibraryBook *book = [self.libraryBooks objectAtIndex:(NSUInteger)indexPath.row];
        cell.textLabel.text = book.bookTitle;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"最新章节:%@", book.latestTitle];
        LibraryViewCellBtn *continueReadBtn = [[LibraryViewCellBtn alloc] init];
        [continueReadBtn setFrame:CGRectMake(0, 0, 60, 35)];
        continueReadBtn.btnIndexPath = indexPath;
        continueReadBtn.delegate = self;
        cell.accessoryView = continueReadBtn;
    }


    return cell;
}

- (void)continueBtnPressedForCellAtIndexPath:(NSIndexPath *)indexPath
{
    ChapterViewController *detailViewController = [[ChapterViewController alloc] init];
    LibraryBook *book = [self.libraryBooks objectAtIndex:(NSUInteger)indexPath.row];
    detailViewController.curBook = book;
    detailViewController.isLoadBookInfo = NO;
    [self.navigationController pushViewController:detailViewController animated:YES];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChapterViewController *detailViewController = [[ChapterViewController alloc] init];
    LibraryBook *book = [self.libraryBooks objectAtIndex:(NSUInteger)indexPath.row];
    detailViewController.curBook = book;
    detailViewController.isLoadBookInfo = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - PullToRefresh
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self loadLibrary];
}

#pragma mark - ProgressHUD
- (void)showProgressHUD:(NSString *)message time:(NSUInteger)time
{
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = message;
    if (time != 0)
        self.progressHUD.graceTime = time;
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
}

- (void)hideProgressHUD
{
    [self.progressHUD hide:YES];
    self.progressHUD = nil;
}

@end

