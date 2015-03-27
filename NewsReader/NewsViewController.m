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
#import "TileViewManager.h"

#warning TO DO: Re-factor this VC into smaller classes

@interface NewsViewController () <UIAlertViewDelegate, UIScrollViewDelegate, ActionMenuViewDelegate, TileViewManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet ActionMenuView *actionMenuView;

@property (strong, nonatomic) TileViewManager *tileManager;

- (IBAction)changeNewsContentTapped:(id)sender;

@end

@implementation NewsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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

// This is called after the auto layout constraints of the view have been applied.
//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//}

#pragma mark - View Setup Methods

- (void)setupView {
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"egg_shell"]];
    self.view.backgroundColor = patternColor;
    
    self.tileManager = [[TileViewManager alloc] initWithScrollView:self.scrollView];
    self.tileManager.delegate = self;
    
    self.actionMenuView.delegate = self;
    [self.actionMenuView configMenuActions];
}

#pragma mark - Load Data Methods

- (void)loadNewsWithQuery:(NSString *)query {
    
    [SVProgressHUD showWithStatus:@"Loading news"];
    [News getNewsByKeyword:query block:^(NSError *error, NSDictionary *response) {
        if (error) {
            DLog(@"Error getting news");
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error loading news: %@", [error localizedDescription]]];
        } else {
            NSArray *news = response[@"news"];
            self.tileManager.newsItems = news;
            [self.tileManager clearScrollView];
            
            // Load the first 3 tiles, instead of loading all of them
            for (int tileIndex=0; tileIndex <= 2; tileIndex++) {
                [self.tileManager addTileWithIndex:tileIndex];
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
    
    for (UIView *newsTile in [scrollView subviews]) {
        [newsTile setNeedsLayout];
    }
    
    [self.actionMenuView updateActionMenuLayoutWithScrollViewOffset:[self.tileManager relativeOffset] scrollView:self.scrollView];
    [self.tileManager repositionTiles];
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
    int currentTileIndex = [self.tileManager currentTileIndex];
    UIView *view = [self.scrollView viewWithTag:[self.tileManager getTagFromIndex:currentTileIndex]];
    
    if ([view isKindOfClass:[NewsTileView class]]) {
        NewsTileView *tile = (NewsTileView *)view;
        [self shareText:tile.news.webTitle andImage:nil andUrl:tile.news.fullURL];
    } else {
        DLog(@"Error finding the current tile view");
    }
}

- (void)centerActionButtonTapped:(ActionMenuView *)actionMenuView {
    int currentTileIndex = [self.tileManager currentTileIndex];
    UIView *view = [self.scrollView viewWithTag:[self.tileManager getTagFromIndex:currentTileIndex]];
    
    if ([view isKindOfClass:[NewsTileView class]]) {
        [self tileTapped:(NewsTileView *)view];
    } else {
        DLog(@"Error finding the current tile view");
    }
}

- (void)rightActionButtonTapped:(ActionMenuView *)actionMenuView {
    [SVProgressHUD showErrorWithStatus:@"Not yet implemented."];
}

#pragma mark - TileViewManagerDelegate Methods

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

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url {
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
