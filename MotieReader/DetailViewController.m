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
{
    NSMutableString *alertConformURL, *alertCancelURL;
}

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

    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];

    if (self.detailItem) {

        self.detailedWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-88)];

        self.detailedWebView.delegate = self;

        [self addToolBar];
    }

    [self configureView];
}

- (void)addToolBar
{
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.height-88, self.view.frame.size.width, 44);
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *downloadBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(downloadContent)];
//    [self.toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,downloadBtn, nil]];
    [self.view addSubview:self.toolbar];
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
        self.curURL = [[request mainDocumentURL] absoluteString];
        [self.view bringSubviewToFront:self.toolbar];
        [self.chapterInfo setHidden:NO];
        return NO;
    }
    else if ([[[request mainDocumentURL] path] hasPrefix:@"/m/buy/"])
    {
        return YES;
    }
    else if ([[[request mainDocumentURL] path] hasPrefix:@"/buy/"])
    {
        if ([self.navigationController isNavigationBarHidden])
        {
            [self setMenuHidden:NO];
        }
        [self.chapterInfo setHidden:YES];
        self.prevURL = self.curURL;
        self.nextURL = nil;
        [self setBackForward];
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
        [self showProgressHUD:@"loading" time:0];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.progressHUD)
        [self hideProgressHUD];
}

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
    {
        [self.textView setHidden:NO];
    }
    else
    {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 34, self.view.frame.size.width, self.detailedWebView.frame.size.height-34)];
        self.chapterInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34)];
        self.chapterInfo.textAlignment = NSTextAlignmentCenter;
        [self.chapterInfo setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        [self.chapterInfo setTextColor:[UIColor whiteColor]];
        [self.chapterInfo setBackgroundColor:[UIColor blackColor]];
//        self.chapterInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.chapterInfoBtn.backgroundColor = [UIColor blackColor];
//        [self.chapterInfoBtn setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [self.textView addGestureRecognizer:self.singleTap];
        self.textView.delegate = self;
    }
    self.textView.text = chapterContent;
    [self.textView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
//    [self.view addSubview:self.chapterInfoBtn];
    if (!self.isFullScreen)
        [self.view addSubview:self.chapterInfo];
    [self.detailedWebView setHidden:YES];
    // 8
    [self.objects addObject:chapterContent];

    // load alert
    tutorialsXpathQueryString = @"//div[@id='bd']/div";
    tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];

    NSMutableString *alertMessage = [NSMutableString string];
    for (TFHppleElement *element in tutorialsNodes)
    {
        if ([[[element firstChild] content] hasPrefix:@"收藏"])
            alertMessage = [[[element firstChild] content] mutableCopy];
        else if ([[[element firstChild] content] hasPrefix:@"您上次"])
            alertMessage = [[[element firstChild] content] mutableCopy];
    }

    tutorialsXpathQueryString = @"//div[@id='bd']/div[@class='alert']/a";
    tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];

    alertConformURL = [NSMutableString string];
    alertCancelURL = [NSMutableString string];
    for (TFHppleElement *element in tutorialsNodes)
    {
        if ([[[element firstChild] content] isEqualToString:@"确定"])
            alertConformURL = [[element attributes] valueForKey:@"href"];
        else if ([[[element firstChild] content] isEqualToString:@"取消"])
            alertCancelURL = [[element attributes] valueForKey:@"href"];
    }

    if ([alertMessage isEqualToString:@""] && [alertConformURL isEqualToString:@""])
        return;
    else
        [self loadAlert:@"chapter alert" message:alertMessage];
}

- (void)loadAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    if ([message hasPrefix:@"收藏"])
    {
        alert = [[UIAlertView alloc] initWithTitle:message
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"取消"
                              otherButtonTitles:@"确定", nil];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:[message substringFromIndex:message.length-12]
                                      message:[message substringToIndex:[message length]-13]
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      otherButtonTitles:@"确定", nil];
    }

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
      //cancel clicked

    }
    else if (buttonIndex == 1)
    {
      // conform clicked
      // load conform URL
        if ([alertConformURL hasPrefix:@"http"])
            [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:alertConformURL]]];
        else
            [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, alertConformURL]]]];
    }
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

    [self setBackForward];

    tutorialsXpathQueryString = @"//div[@id='bd']/h3";
    tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];

    for (TFHppleElement *element in tutorialsNodes)
    {
        self.chapterInfo.text = [[element firstChild] content];
    }


}

- (void)setBackForward
{
    UIBarButtonItem *nextBtn = nil;
    UIBarButtonItem *prevBtn = nil;
    self.navigationItem.rightBarButtonItems = nil;
    if (self.nextURL)
    {
        nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleBordered target:self action:@selector(loadNextChapter)];
    }
    else
    {
        nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleBordered target:self action:@selector(loadNextChapter)];
        [nextBtn setEnabled:NO];
    }
    if (self.prevURL)
    {
        prevBtn = [[UIBarButtonItem alloc] initWithTitle:@"prev" style:UIBarButtonItemStyleBordered target:self action:@selector(loadPrevChapter)];
    }
    else
    {
        prevBtn = [[UIBarButtonItem alloc] initWithTitle:@"prev" style:UIBarButtonItemStyleBordered target:self action:@selector(loadPrevChapter)];
        [prevBtn setEnabled:NO];
    }

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.toolbar setItems:[NSArray arrayWithObjects:flexibleSpace,prevBtn,nextBtn, nil]];

//    if (nextBtn && prevBtn)
//        self.navigationItem.rightBarButtonItems = @[nextBtn, prevBtn];
//    else if (nextBtn && !prevBtn)
//        self.navigationItem.rightBarButtonItem = nextBtn;
//    else if (prevBtn && !nextBtn)
//        self.navigationItem.rightBarButtonItem = prevBtn;
//    else
//        self.navigationItem.rightBarButtonItem = nil;
}

- (void)loadNextChapter
{
    if (self.nextURL)
        [self loadNewChapter:self.nextURL];
    else
        [[[[iToast makeText:NSLocalizedString(@"This is already the last chapter.", @"")]
                    setGravity:iToastGravityCenter] setDuration:1000] show];
}

- (void)loadPrevChapter
{
    if (self.prevURL)
        [self loadNewChapter:self.prevURL];
    else
        [[[[iToast makeText:NSLocalizedString(@"This is already the first chapter.", @"")]
                            setGravity:iToastGravityCenter] setDuration:1000] show];
}

- (void)loadNewChapter:(NSString *)URL
{
    [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"about:blank"]]]];
    [self.detailedWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
}

#pragma mark gestureRecognizer

- (void)didTap:(UITapGestureRecognizer *)sender
{
    CGPoint touchLocation = [sender locationInView:self.textView];
    CGFloat viewWidth = self.textView.frame.size.width;

    if (touchLocation.x <= viewWidth * 0.25)
    {
        [self loadPrevChapter];
    }
    else if (touchLocation.x >= viewWidth * 0.75)
    {
        [self loadNextChapter];
    }
    else
    {
        [self setMenuHidden:![self.navigationController isNavigationBarHidden]];
    }
}

- (void)setMenuHidden:(BOOL)hidden
{
    if (hidden)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.toolbar removeFromSuperview];
        [self.chapterInfo removeFromSuperview];
        [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, 0, self.textView.frame.size.width, self.textView.frame.size.height+142)];
        [self.detailedWebView setFrame:CGRectMake(0, 0, self.detailedWebView.frame.size.width, self.detailedWebView.frame.size.height+108)];
        self.isFullScreen = YES;
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self.view addSubview:self.toolbar];
        [self.view addSubview:self.chapterInfo];
        [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, 34, self.textView.frame.size.width, self.textView.frame.size.height-142)];
        [self.detailedWebView setFrame:CGRectMake(0, 0, self.detailedWebView.frame.size.width, self.detailedWebView.frame.size.height-108)];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.isFullScreen = NO;
    }
}

#pragma mark UITextView delegate

@end
