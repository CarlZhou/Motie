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
#import "Tutorial.h"
#import "Contributor.h"

@interface LibraryController () {
    NSMutableArray *_objects;
    NSMutableArray *_contributors;
}
@end

@implementation LibraryController

@synthesize detailViewController = _detailViewController;

- (void)loadTutorials {
    // 1
    NSURL *tutorialsUrl = [NSURL URLWithString:self.LibraryURL];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];

    // 2
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];

    // 3
    NSString *tutorialsXpathQueryString = @"//div[@class='txtbox-item']/a";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];

    // 4
    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in tutorialsNodes) {
        // 5
        Tutorial *tutorial = [[Tutorial alloc] init];
        [newTutorials addObject:tutorial];

        // 6
        tutorial.title = [[element firstChild] content];
        if (!tutorial.title)
            tutorial.title = @"继续阅读";

        // 7
        tutorial.url = [element objectForKey:@"href"];
    }

    // 8
    _objects = newTutorials;
    [self.tableView reloadData];
}

- (void)loadContributors {
    // 1
    NSURL *contributorsUrl = [NSURL URLWithString:@"http://www.raywenderlich.com/"];
    NSData *contributorsHtmlData = [NSData dataWithContentsOfURL:contributorsUrl];

    // 2
    TFHpple *contributorsParser = [TFHpple hppleWithHTMLData:contributorsHtmlData];

    // 3
    NSString *contributorsXpathQueryString = @"//div[@id='contributors']/div[@id='moderator']/a";
    NSArray *contributorsNodes = [contributorsParser searchWithXPathQuery:contributorsXpathQueryString];

    // 4
    NSMutableArray *newContributors = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in contributorsNodes) {
        // 5
        Contributor *contributor = [[Contributor alloc] init];
        [newContributors addObject:contributor];

        // 6
        contributor.url = [element objectForKey:@"href"];

        // 7
        for (TFHppleElement *child in element.children) {
            if ([child.tagName isEqualToString:@"img"]) {
                // 8
                contributor.imageUrl = [child objectForKey:@"src"];
            } else if ([child.tagName isEqualToString:@"p"]) {
                // 9
                contributor.name = [[child firstChild] content];
            }
        }
    }

    // 10
    _contributors = newContributors;
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
    [self loadTutorials];
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

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0:
//            return @"Books";
//            //        case 1:
//            //            return @"Contributors";
//    }
//    return nil;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _objects.count;
            //        case 1:
            //            return _contributors.count;
            //            break;
    }
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    if (indexPath.section == 0)
    {
        Tutorial *thisTutorial = [_objects objectAtIndex:indexPath.row];
        if ([thisTutorial.url hasPrefix:@"http://"])
        {
            cell.textLabel.text = @"最新章节:";
            cell.detailTextLabel.text = thisTutorial.title;
        }
        else
        {
            cell.textLabel.text = thisTutorial.title;
            cell.detailTextLabel.text = nil;
        }
        //        cell.detailTextLabel.text = thisTutorial.url;
    }
    //    } else if (indexPath.section == 1) {
    //        Contributor *thisContributor = [_contributors objectAtIndex:indexPath.row];
    //        cell.textLabel.text = thisContributor.name;
    //        cell.detailTextLabel.text = thisContributor.url;
    //    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (!self.detailViewController) {
//        self.detailViewController = [[ChapterViewController alloc] init];
//    }
    ChapterViewController *detailViewController = [[ChapterViewController alloc] init];
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    detailViewController.detailItem = object;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end

