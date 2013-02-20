//
//  DetailViewController.m
//  MotieReader
//
//  Created by Carl on 2013-02-19.
//  Copyright (c) 2013 Carl. All rights reserved.
//

#import "DetailViewController.h"

#import "TFHpple.h"
#import "Tutorial.h"

#define BASE_URL @"http://m.motie.com"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"about:blank"]]]];

    if (self.detailItem) {
        NSString *bookURL = [self.detailItem valueForKey:@"url"];

        if ([bookURL hasPrefix:@"http://"])
            [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.detailItem valueForKey:@"url"]]]]];
        else
            [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL,[self.detailItem valueForKey:@"url"]]]]];
        [self.view addSubview:self.detailedWebView];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    if (self.detailItem) {

        self.detailedWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-88)];

        self.detailedWebView.delegate = self;
        
        [self addToolBar];
    }

    [self configureView];
}

- (void)addToolBar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *downloadBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(downloadContent)];
    [items addObject:downloadBtn];
//    [items addObject:[[[UIBarButtonItem alloc] initWith....] autorelease]];
    [toolbar setItems:items animated:NO];
    [self.view addSubview:toolbar];
}

- (void)downloadContent
{
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

#pragma mark web
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request mainDocumentURL] path] hasPrefix:@"/ajax/"])
    {
        [self loadBook:[request mainDocumentURL]];
        [self loadInfo:[request mainDocumentURL]];
        return NO;
    }
    else if ([[[request mainDocumentURL] path] hasPrefix:@"/m/buy/"])
    {
        return YES;
    }
    else if ([[[request mainDocumentURL] path] hasPrefix:@"/buy/"])
    {
        return YES;
    }
    else
    {
        if (self.detailedWebView)
            [self.detailedWebView setHidden:NO];
        if (self.textView)
            [self.textView setHidden:YES];
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!self.progressHUD)
        [self showProgressHUD:@"loading"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.progressHUD)
        [self hideProgressHUD];
}

- (void)showProgressHUD:(NSString *)message
{
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = message;
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
}

- (void)hideProgressHUD
{
    [self.progressHUD hide:YES];
    self.progressHUD = nil;
}

#pragma mark parse book

- (void)loadBook:(NSURL *)URL {
    // 1
    NSURL *tutorialsUrl = URL;
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];

    // 2
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];

    // 3
    NSString *tutorialsXpathQueryString = @"//div[@id='bd']/p";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];

    // 4
    NSMutableString *chapterContent = [NSMutableString string];
    for (TFHppleElement *element in tutorialsNodes) {

        for (TFHppleElement *subelement in [element children])
        {
            if ([subelement content])
            {
                [chapterContent appendString:[[subelement content] substringToIndex:[[subelement content] length]-1]];
                [chapterContent appendString:@"\n"];
            }
        }
    }

    if (self.textView)
        [self.textView setHidden:NO];
    else
        self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
    self.textView.text = chapterContent;
    [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
    [self.detailedWebView setHidden:YES];
    // 8
    [self.objects addObject:chapterContent];
}

- (void)loadInfo:(NSURL *)URL
{
    // 1
    NSURL *tutorialsUrl = URL;
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];

    // 2
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];

    // 3
    NSString *tutorialsXpathQueryString = @"//div[@id='bd']/a";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];

    self.nextURL = nil;
    self.prevURL = nil;

    for (TFHppleElement *element in tutorialsNodes)
    {
        //        NSLog(@"A:%@", [[element attributes] valueForKey:@"href"]);
        //        NSLog(@"C:%@", [[element firstChild] content]);
        if ([[[element firstChild] content] isEqualToString:@"下一章"])
        {
            self.nextURL = [[element attributes] valueForKey:@"href"];
        }
        else if ([[[element firstChild] content] isEqualToString:@"上一章"])
        {
            self.prevURL = [[element attributes] valueForKey:@"href"];
        }
    }

    UIBarButtonItem *nextBtn = nil;
    UIBarButtonItem *prevBtn = nil;
    self.navigationItem.rightBarButtonItems = nil;
    if (self.nextURL)
    {
        nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleBordered target:self action:@selector(loadNextChapter)];
    }
    if (self.prevURL)
    {
        prevBtn = [[UIBarButtonItem alloc] initWithTitle:@"prev" style:UIBarButtonItemStyleBordered target:self action:@selector(loadPrevChapter)];
    }

    if (nextBtn && prevBtn)
        self.navigationItem.rightBarButtonItems = @[nextBtn, prevBtn];
    else if (nextBtn && !prevBtn)
        self.navigationItem.rightBarButtonItem = nextBtn;
    else if (prevBtn && !nextBtn)
        self.navigationItem.rightBarButtonItem = prevBtn;
    else
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)loadNextChapter
{
    if (self.nextURL)
        [self loadNewChapter:self.nextURL];
}

- (void)loadPrevChapter
{
    if (self.prevURL)
        [self loadNewChapter:self.prevURL];
}

- (void)loadNewChapter:(NSString *)URL
{
    [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"about:blank"]]]];
    [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
}

@end
