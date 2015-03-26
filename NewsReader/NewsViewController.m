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

#warning TO DO: Re-factor this VC into smaller classes

@interface NewsViewController () <UIAlertViewDelegate, UIScrollViewDelegate, ActionMenuViewDelegate>

- (IBAction)changeNewsContentTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet ActionMenuView *actionMenuView;

@property (strong, nonatomic) NSArray *newsItems;
@property (strong, nonatomic) NSMutableSet *recycledTiles;
@property (strong, nonatomic) NSMutableSet *visibleTiles;

@property (nonatomic) int selectedTileIndex;

@end

@implementation NewsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupView];
    
    self.recycledTiles = [[NSMutableSet alloc] initWithObjects:nil];
    self.visibleTiles = [[NSMutableSet alloc] initWithObjects:nil];
    
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
            self.newsItems = news;
            //            DLog(@"Fetched %lu news articles", (unsigned long)news.count);
            
            [self clearScrollView];
            
            // Load the first 3 tiles, instead of loading all of them
            for (int tileIndex=0; tileIndex <= 2; tileIndex++) {
                [self addTileWithIndex:tileIndex];
            }
            
            //            DLog(@"Number of visible tiles: %lu", (unsigned long)self.visibleTiles.count);
            //            DLog(@"Number of recycled tiles: %lu", (unsigned long)self.recycledTiles.count);
            
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
    
    [self.actionMenuView updateActionMenuLayoutWithScrollViewOffset:[self relativeOffset] scrollView:self.scrollView];
    [self repositionTiles];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    @try {
        [self.actionMenuView enableActionsAfterScroll];
    }
    @catch (NSException *exception) {
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

#pragma mark - NewsTileDelegate Methods

- (float)viewOffsetForScaling:(NewsTile *)tile {
    
    float diff = (self.scrollView.contentOffset.x + (tile.frame.size.width / 2)) - tile.center.x;
    
    if (diff > tile.initialFrame.size.width) {
        diff = tile.initialFrame.size.width;
    }
    else if ( diff < -tile.initialFrame.size.width) {
        diff = -tile.initialFrame.size.width;
    }
    
    return diff;
}

- (void)tileTapped:(NewsTile *)tile {
    WebBrowserViewController *webViewController = [[WebBrowserViewController alloc] initWithURL:tile.news.fullURL];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    
    [self presentViewController:navController animated:YES completion:^{
        //
    }];
}

#pragma mark - ActionMenuViewDelegate Methods

- (void)leftActionButtonTapped:(ActionMenuView *)actionMenuView {
    int currentTileIndex = [self currentTileIndex];
    UIView *view = [self.scrollView viewWithTag:[self getTagFromIndex:currentTileIndex]];
    if ([view isKindOfClass:[NewsTile class]]) {
        NewsTile *tile = (NewsTile *)view;
        [self shareText:tile.news.webTitle andImage:nil andUrl:tile.news.fullURL];
    } else {
        DLog(@"Error finding the current tile view");
    }
}

- (void)centerActionButtonTapped:(ActionMenuView *)actionMenuView {
    int currentTileIndex = [self currentTileIndex];
    UIView *view = [self.scrollView viewWithTag:[self getTagFromIndex:currentTileIndex]];
    if ([view isKindOfClass:[NewsTile class]]) {
        [self tileTapped:(NewsTile *)view];
    } else {
        DLog(@"Error finding the current tile view");
    }
}

- (void)rightActionButtonTapped:(ActionMenuView *)actionMenuView {
    [SVProgressHUD showErrorWithStatus:@"Not yet implemented."];
}

#pragma mark - IBAction Methods

- (IBAction)changeNewsContentTapped:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a search query below:" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Load News", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - Tile Re-Use Methods

- (int)getArrayIndexFromTileViewTag:(int)tag {
    return tag - 100;
}

- (int)getTagFromIndex:(int)index {
    return index + 100;
}

- (void)clearScrollView {
    
    // Empty scroll view and put all the visible tile views into the recycled set (if there are any)
    for (UIView *subview in self.visibleTiles) {
        [subview removeFromSuperview];
        [self.recycledTiles addObject:subview];
    }
    
    [self.visibleTiles minusSet:self.recycledTiles];
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    BOOL foundPage = NO;
    for (NewsTile *page in self.visibleTiles) {
        if ([self getArrayIndexFromTileViewTag:(int)page.tag] == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)addTileWithIndex:(int)index {
    if (index >= 0 && index < [self.newsItems count]) {
        
        News *news = (News *) [self.newsItems objectAtIndex:index];
        NewsTile *tile = [self dequeueReusableTileView];
        CGRect tileFrame = CGRectMake(index*self.scrollView.frame.size.width + 10, 10,
                                      self.scrollView.bounds.size.width - 20, self.scrollView.bounds.size.height - 20);
        if (tile) {
//            DLog(@"Re-using tile.");
            tile.news = news;
            tile.frame = tileFrame;
        } else {
//            DLog(@"Creating new tile.");
            tile = [[NewsTile alloc] initWithFrame:tileFrame news:news];
        }
        
        tile.delegate = self;
        tile.tag = [self getTagFromIndex:index];
        [self.scrollView addSubview:tile];
        
        // Add tile to currently visible tiles array
        [self.visibleTiles addObject:tile];
        
    } else {
        DLog(@"No tile found for requested news tile view");
    }
}

- (void)repositionTiles {
    
    int currentTileIndex = [self currentTileIndex];
    
    if (currentTileIndex != self.selectedTileIndex) {
        
        int firstNeededTileIndex = (int)MIN(MAX(currentTileIndex - 1, 0), self.newsItems.count - 3);
        int lastNeededTileIndex  = (int)MAX(MIN(currentTileIndex + 1, self.newsItems.count - 1), 2);
        
        //        DLog(@"First page tile index: %d", firstNeededTileIndex);
        //        DLog(@"Last page tile index: %d", lastNeededTileIndex);
        
        if (self.newsItems.count > 3) {
            
            // Put any visible tiles that are no longer needed into the recycled set
            for (NewsTile *tile in self.visibleTiles) {
                if (tile.tag < [self getTagFromIndex:firstNeededTileIndex] || tile.tag > [self getTagFromIndex:lastNeededTileIndex]) {
                    //                    DLog(@"Recycling tile with tag: %ld", (long)tile.tag);
                    [self.recycledTiles addObject:tile];
                    [tile removeFromSuperview];
                }
            }
            
            [self.visibleTiles minusSet:self.recycledTiles];
            
            //            DLog(@"Number of visible tiles: %lu", (unsigned long)self.visibleTiles.count);
            //            DLog(@"Number of recycled tiles: %lu", (unsigned long)self.recycledTiles.count);
            
            
            // Add missing tile views
            for (int index = firstNeededTileIndex; index <= lastNeededTileIndex; index++) {
                if (![self isDisplayingPageForIndex:index]) {
                    [self addTileWithIndex:index];
                }
            }
        }
        
        self.selectedTileIndex = currentTileIndex;
        
        //        DLog(@"Number of visible tiles: %lu", (unsigned long)self.visibleTiles.count);
        //        DLog(@"Number of recycled tiles: %lu", (unsigned long)self.recycledTiles.count);
    }
}

- (NewsTile *)dequeueReusableTileView {
    NewsTile *tileView = [self.recycledTiles anyObject];
    if (tileView) {
        [self.recycledTiles removeObject:tileView];
    }
    return tileView;
}

- (int)currentTileIndex {
    float offset = self.scrollView.contentOffset.x;
    float contentSize = self.scrollView.contentSize.width;
    float width = self.scrollView.frame.size.width;
    
    // don't process when bouncing beyond the range of the scroll view
    // clamp offset value between first and last tiles
    offset = clamp(offset, 0., contentSize - width);
    
    // now divide into the number of tiles
    int tileIndex = roundf(offset / width);
    
    //    DLog (@"Current tile index: %d", tileIndex);
    return tileIndex;
}

/**
 * This calculates the current offset of the scroll view, amount of horizontal distance from a stable point.
 */
- (float)relativeOffset {
    
    float offset = self.scrollView.contentOffset.x;
    float contentSize = self.scrollView.contentSize.width;
    float width = self.scrollView.frame.size.width;
    
    offset = clamp(offset, 0., contentSize - width);
    offset = fmodf(offset, width);
    
    return offset;
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
