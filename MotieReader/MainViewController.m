//
//  MainViewController.m
//  MotieReader
//
//  Created by Zian Zhou on 2013-02-21.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import "MainViewController.h"
#import "TFHpple.h"
#import "LibraryController.h"

#define MAIN_PAGE @"http://m.motie.com/"
#define LOGIN_PAGE @"http://m.motie.com/accounts/login"
#define REGISTER_PAGE @"http://m.motie.com/accounts/register"

@interface MainViewController ()

@end

@implementation MainViewController
{
    BOOL viewDidShown;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UIImage *bgImage = [[UIImage imageNamed:@"Default-Portrait@2x~ipad.png"] stretchableImageWithLeftCapWidth:768 topCapHeight:1004];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:bgImage];
    [self.backgroundImageView setFrame:self.view.frame];
    [self.view addSubview:self.backgroundImageView];
    [self loadMainPage:MAIN_PAGE];
}

- (void)viewDidAppear:(BOOL)animated
{
    viewDidShown = YES;
    if (self.URL)
    {
        [self presentLibrary];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    viewDidShown = NO;
}

- (void)presentLibrary
{
    LibraryController *libraryViewController = [[LibraryController alloc] init];
    id delegate = [[UIApplication sharedApplication] delegate];
    libraryViewController.managedObjectContext = [delegate managedObjectContext];
    libraryViewController.LibraryURL = self.URL;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:libraryViewController];
    [navigationController.navigationBar setTintColor:[UIColor lightGrayColor]];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMainPage:(NSString *)URL
{
    // 1
    NSURL *loadURL = [NSURL URLWithString:URL];
    NSData *loadURLHtmlData = [NSData dataWithContentsOfURL:loadURL];

    // 2
    TFHpple *URLParser = [TFHpple hppleWithHTMLData:loadURLHtmlData];

    // 3 Test Login
    NSString *URLXpathQueryString = @"//p[@class='not-login']";
    NSArray *urlInfoNodes = [URLParser searchWithXPathQuery:URLXpathQueryString];

    // 4
    for (TFHppleElement *element in urlInfoNodes) {

    }
    if (urlInfoNodes.count != 0)
    {
        [self.backgroundImageView removeFromSuperview];
        self.mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.mainWebView.delegate = self;
        self.mainWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:LOGIN_PAGE]]];
        [self.view addSubview:self.mainWebView];
        return;
    }

    URLXpathQueryString = @"//div[@class='nav']";
    urlInfoNodes = [URLParser searchWithXPathQuery:URLXpathQueryString];
    for (TFHppleElement *element in urlInfoNodes)
    {
        for (TFHppleElement *subElement in [element children])
        {
            if ([[[subElement firstChild] content] isEqualToString:@"书架 "])
            {
                self.URL = [[subElement attributes] valueForKey:@"href"];
                if (viewDidShown)
                    [self presentLibrary];
                return;
                }
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([[[[webView request] mainDocumentURL] query] hasPrefix:@"sd="])
    {
        [self.mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        [self loadMainPage:MAIN_PAGE];
    }
}


@end
