//
//  ViewController.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/22/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "NewsViewController.h"
#import "Macros.h"
#import "News.h"
#import "WebBrowserViewController.h"
#import "SVProgressHUD.h"
#import "ActionMenuView.h"
#import "TileScrollViewManager.h"
#import "NewsTileView.h"

@interface NewsViewController () <UIAlertViewDelegate, UIScrollViewDelegate, ActionMenuViewDelegate, TileScrollViewManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet ActionMenuView *actionMenuView;

@property (strong, nonatomic) TileScrollViewManager *scrollViewManager;

- (IBAction)changeNewsContentTapped:(id)sender;

@end

@implementation NewsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self loadNewsWithQuery:@"France"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Setup Methods

- (void)setupView {
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"egg_shell"]];
    self.view.backgroundColor = patternColor;
    
    self.scrollViewManager = [[TileScrollViewManager alloc] initWithScrollView:self.scrollView];
    self.scrollViewManager.delegate = self;
    
    self.actionMenuView.delegate = self;
    [self.actionMenuView setup];
}

#pragma mark - Load Data Methods

- (void)loadNewsWithQuery:(NSString *)query {
    
    [SVProgressHUD showWithStatus:@"Loading news"];
    [News getNewsByKeyword:query block:^(NSError *error, NSDictionary *response) {
        if (error) {
            DLog(@"Error getting news: %@", [error localizedDescription]);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error loading news: %@", [error localizedDescription]]];
        } else {
            NSArray *news = response[@"news"];
            self.scrollViewManager.newsItems = news;
            [self.scrollViewManager clearScrollView];
            
            // Load the first 3 tiles, instead of loading all of them
            for (int tileIndex=0; tileIndex <= 2; tileIndex++) {
                [self.scrollViewManager addTileWithIndex:tileIndex];
            }
            
            // Set scroll view content size, and move it back to start
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * news.count, self.scrollView.frame.size.height);
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            
            [SVProgressHUD showSuccessWithStatus:@"Success"];
        }
    }];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (UIView *view in [scrollView subviews]) {
        [view setNeedsLayout];
    }
    
    [self.actionMenuView updateActionMenuLayoutWithScrollViewOffset:[self.scrollViewManager scrollViewRelativeOffset] scrollView:self.scrollView];
    [self.scrollViewManager repositionTiles];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {    
    @try {
        [self.actionMenuView enableActionsAfterScroll];
    } @catch (NSException *exception) {
        DLog(@"Exception after scrolling: %@", exception);
    }
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // If load news button is tapped
    if (buttonIndex == 1) {
        UITextField *textfield = [alertView textFieldAtIndex: 0];
        NSString *searchQuery = textfield.text;
        [self loadNewsWithQuery:searchQuery];
    }
}

#pragma mark - ActionMenuViewDelegate Methods

- (void)leftActionButtonTapped:(ActionMenuView *)actionMenuView {
    NewsTileView *tile = [self.scrollViewManager currentTileView];
    
    if (tile) {
        [self shareText:tile.news.webTitle image:nil url:tile.news.fullURL];
    }
}

- (void)centerActionButtonTapped:(ActionMenuView *)actionMenuView {
    NewsTileView *tile = [self.scrollViewManager currentTileView];
    
    if (tile) {
        [self tileTapped:tile];
    }
}

- (void)rightActionButtonTapped:(ActionMenuView *)actionMenuView {
    [SVProgressHUD showErrorWithStatus:@"Not yet implemented."];
}

#pragma mark - TileScrollViewManagerDelegate Methods

- (void)tileTapped:(NewsTileView *)tile {
    WebBrowserViewController *webViewController = [[WebBrowserViewController alloc] initWithURL:tile.news.fullURL];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webViewController];

    [self presentViewController:navController animated:YES completion:^{
        //
    }];
}

#pragma mark - IBAction Methods

- (IBAction)changeNewsContentTapped:(id)sender {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a search query below:" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Load News", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - Other Helper Methods

- (void)shareText:(NSString *)text image:(UIImage *)image url:(NSURL *)url {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    });
}

@end
