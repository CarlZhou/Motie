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

@interface LibraryController () {
}
@end

@implementation LibraryController

@synthesize detailViewController = _detailViewController;

- (void)loadLibrary
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

    self.libraryBooks = libraryBooks;
    [self.tableView reloadData];
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
    [self loadLibrary];
    //    [self loadContributors];
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

@end

