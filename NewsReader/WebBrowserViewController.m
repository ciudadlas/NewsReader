//
//  SKNWebViewController.m
//  SKNWebBrowser
//
//  Created by Serdar Karatekin on 2/28/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "WebBrowserViewController.h"

static void *WebContext = &WebContext;

@interface WebBrowserViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSURL *initialURL;

@end

@implementation WebBrowserViewController

#pragma mark - View Lifecycle

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        _initialURL = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
    // Remove progress view because the navigation bar is shared across view controllers
    [self.progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self deregisterNotifications];
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
}

#pragma mark - Notifications

- (void)registerNotifications {
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:WebContext];
}

- (void)deregisterNotifications {
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) context:WebContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        
        // Animate progress view if there is more progress made
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        
        // Once web page has fully loaded, fade out the progress view
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.25f delay:0.25f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                // Set progress of the view back to 0
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - View Setup Helpers

- (void)setupView {
    [self setupNavigationBar];
    [self setupWebView];
    [self setupBottomBar];
    [self setupProgressView];
    [self updateBarButtonItemsState];
}

- (void)setupWebView {
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webViewConfiguration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.multipleTouchEnabled = YES;
    self.webView.autoresizesSubviews = YES;
    self.webView.scrollView.alwaysBounceVertical = YES;

    [self.view addSubview:self.webView];
    
    if (self.initialURL) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.initialURL]];
    }
}

- (void)setupNavigationBar {
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:(UIBarButtonSystemItemStop)
                                    target:self
                                    action:@selector(closeButtonTapped:)];
    
    self.navigationItem.rightBarButtonItem = closeButton;

    self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
}

- (void)setupBottomBar {
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    separator.width = 25.f;
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonTapped:)];
    
    self.toolbarItems = @[self.backButton, separator, self.forwardButton];
    
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.translucent = NO;
}

- (void)setupProgressView {
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor clearColor]];
    CGRect progressViewFrame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height - self.progressView.frame.size.height,
                                          self.view.frame.size.width, self.progressView.frame.size.height);
    [self.progressView setFrame:progressViewFrame];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
}

#pragma mark - View Update Helpers

- (void)updateBarButtonItemsState {
    self.forwardButton.enabled = self.webView.canGoForward;
    self.backButton.enabled = self.webView.canGoBack;
}

- (void)updateSearchBarUrl {
#warning TO DO: These should be cleaned up
//    NSString *URLString = [self.webView.URL host];
//    
//    URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
//    URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
//    
//    self.urlBar.text = URLString;
}

#pragma mark - Navigation Bar Action Handling

- (void)closeButtonTapped:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark - Bottom Toolbar Action Handling

- (void)backButtonTapped:(id)sender {
    [self.webView goBack];
}

- (void)forwardButtonTapped:(id)sender {
    [self.webView goForward];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
    
    // TODO: Here if progress bar hasnt been set back to 0, set it back.
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    // This is needed to get links with target="_blank" attribute to open on the same page
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end