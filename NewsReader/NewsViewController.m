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

@interface NewsViewController () <UIAlertViewDelegate>

- (IBAction)changeNewsContentTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *leftAction;
@property (weak, nonatomic) IBOutlet UIView *centerAction;
@property (weak, nonatomic) IBOutlet UIView *rightAction;

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

#pragma mark - View Setup Helpers

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
        if (page.tag - 100 == index) {
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
            DLog(@"Re-using tile.");
            tile.news = news;
            tile.frame = tileFrame;
        } else {
            DLog(@"Creating new tile.");
            tile = [[NewsTile alloc] initWithFrame:tileFrame news:news];
        }
        
        tile.delegate = self;
        tile.tag = 100 + index;
        [self.scrollView addSubview:tile];
        
        // Add tile to currently visible tiles array
        [self.visibleTiles addObject:tile];
    } else {
        DLog(@"No tile found for requested news tile view");
    }
}

- (void)setupView {
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"egg_shell"]];
    self.view.backgroundColor = patternColor;
    
    [self configMenuActions];
}

- (void)loadNewsWithQuery:(NSString *)query {
    
    [SVProgressHUD showWithStatus:@"Loading news"];
    [News getNewsByKeyword:query block:^(NSError *error, NSDictionary *response) {
        if (error) {
            DLog(@"Error getting news");
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error loading news: %@", [error localizedDescription]]];
        } else {
            NSArray *news = response[@"news"];
            self.newsItems = news;
            
            DLog(@"Fetched %lu news articles", (unsigned long)news.count);
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            
            [self clearScrollView];
            
            // Load 3 tiles, instead of loading all of them
            for (int tileIndex=0; tileIndex <= 2; tileIndex++) {
                [self addTileWithIndex:tileIndex];
            }
            
            DLog(@"Number of visible tiles: %lu", (unsigned long)self.visibleTiles.count);
            DLog(@"Number of recycled tiles: %lu", (unsigned long)self.recycledTiles.count);

            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * news.count, self.scrollView.frame.size.height);
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
    }];
}

#pragma mark - Helper Methods

- (void)updateTiles {
    
    int currentTileIndex = [self currentTileIndex];
    
    if (currentTileIndex != self.selectedTileIndex) {
        
        int firstNeededPageIndex = (int)MIN(MAX(currentTileIndex - 1, 0), self.newsItems.count - 3);
        int lastNeededPageIndex  = (int)MAX(MIN(currentTileIndex + 1, self.newsItems.count - 1), 2);
        
        DLog(@"First page needed index: %d", firstNeededPageIndex);
        DLog(@"Last page needed index: %d", lastNeededPageIndex);
        
        if (self.newsItems.count > 3) {
            
            // Put any visible tiles that are no longer needed into the recycled set
            for (NewsTile *tile in self.visibleTiles) {
                if (tile.tag < firstNeededPageIndex + 100 || tile.tag > lastNeededPageIndex + 100) {
                    DLog(@"Recycling tile with index: %ld", tile.tag - 100);
                    [self.recycledTiles addObject:tile];
                    [tile removeFromSuperview];
                }
            }
            
            [self.visibleTiles minusSet:self.recycledTiles];
            
            // Add missing tile views
            for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
                if (![self isDisplayingPageForIndex:index]) {
                    [self addTileWithIndex:index];
                }
            }
        }
        
        self.selectedTileIndex = currentTileIndex;
        
        DLog(@"Number of visible tiles: %lu", (unsigned long)self.visibleTiles.count);
        DLog(@"Number of recycled tiles: %lu", (unsigned long)self.recycledTiles.count);
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

// create the proper placement and perspective for the action menu tiles
- (void)configMenuActions {
    
#warning TO DO: Look into why this is happening and a potential fix
     // These are displacing the menu buttons, so avoiding for now.
//    [self setAnchorPoint:CGPointMake(1.5, 0.5) forView:self.leftAction];
//    [self setAnchorPoint:CGPointMake(-0.5, 0.5) forView:self.rightAction];
    
    // Config left action
    UITapGestureRecognizer *tapLeft = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftActionTapped:)];
    tapLeft.numberOfTapsRequired = 1;
    tapLeft.numberOfTouchesRequired = 1;
    [self.leftAction addGestureRecognizer: tapLeft];
    
    // Config center action
    UITapGestureRecognizer *tapCenter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerActionTapped:)];
    tapCenter.numberOfTapsRequired = 1;
    tapCenter.numberOfTouchesRequired = 1;
    [self.centerAction addGestureRecognizer: tapCenter];
    
    // Config right action
    UITapGestureRecognizer *tapRight = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(rightActionTapped:)];
    tapRight.numberOfTapsRequired = 1;
    tapRight.numberOfTouchesRequired = 1;
    [self.rightAction addGestureRecognizer: tapRight];
}

// Taken from: http://stackoverflow.com/a/5666430
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

- (float)relativeOffset {
    
    float offset = self.scrollView.contentOffset.x;
    float contentSize = self.scrollView.contentSize.width;
    float width = self.scrollView.frame.size.width;
    
    // don't process when bouncing beyond the range of the scroll view
    // clamp offset value between first and last tiles
    offset = clamp(offset, 0., contentSize - width);
    
    // now divide into the number of tiles
    offset = fmodf(offset, width);
    
    return offset;
}

- (void)layoutActionMenuForOffset:(float)offset {
    
    // we're splitting the offset into three equally-spaced animations
    // Timeline:      |----|----|----|----|----|
    // Left action:   |--------------|
    // Center action:      |--------------|
    // Right action:            |--------------|
    
    float maxOffset = self.scrollView.frame.size.width;
    // marginalOffset is the width of a single animation
    float marginalOffset = maxOffset / 5.0 * 3.0;
    // iterationGap is the width between sequential animation starts
    float iterationGap = maxOffset / 5;
    
    float leftActionOffset = clamp(offset, 0., marginalOffset);
    float leftActionRotationAmount = leftActionOffset / marginalOffset;
    leftActionRotationAmount = [self transformRotation:leftActionRotationAmount];
    [self rotateAction:self.leftAction byAmount:leftActionRotationAmount];
    
    float centerActionOffset = clamp(offset, iterationGap, marginalOffset + iterationGap);
    centerActionOffset = centerActionOffset - iterationGap;
    float centerActionRotationAmount = centerActionOffset / marginalOffset;
    centerActionRotationAmount = [self transformRotation:centerActionRotationAmount];
    [self rotateAction:self.centerAction byAmount:centerActionRotationAmount];
    
    float rightActionOffset = clamp(offset, iterationGap * 2, maxOffset);
    rightActionOffset = rightActionOffset - (iterationGap * 2);
    float rightActionRotationAmount = rightActionOffset / marginalOffset;
    rightActionRotationAmount = [self transformRotation:rightActionRotationAmount];
    [self rotateAction:self.rightAction byAmount:rightActionRotationAmount];
}

- (float)transformRotation:(float)rotationAmount {
    // map our rotation so it flips back down at the center point and the layer is never upside down
    float returnVal = rotationAmount >= 0.5 ? rotationAmount - 1 : rotationAmount;
    
    // because the layer has no height, it'll disappear for a moment at this value if we don't fix it
    returnVal = returnVal == -0.5 ? -0.4999 : returnVal;
    
    // mapping rotation to a true circular path
    returnVal = asinf(2 * returnVal) / M_PI * 2;
    
    return returnVal;
}

- (void)rotateAction:(UIView *)action byAmount:(float)amount {
    CATransform3D rotationTransform = CATransform3DIdentity;
    
    rotationTransform.m33 = 0.0;
    rotationTransform.m34 = 0.005;
    rotationTransform = CATransform3DRotate(rotationTransform, amount * M_PI / 2, 1.0, 0.0, 0.0);
    
    action.layer.transform = rotationTransform;
}

- (void)enableActionsAfterScroll {
    // Without this, tap gesture recognizers stop working.
    self.leftAction.layer.transform = CATransform3DIdentity;
    self.centerAction.layer.transform = CATransform3DIdentity;
    self.rightAction.layer.transform = CATransform3DIdentity;
}

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

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (UIView *newsTile in [scrollView subviews]) {
        [newsTile setNeedsLayout];
    }
    
    [self layoutActionMenuForOffset:[self relativeOffset]];
    [self updateTiles];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    @try {
        [self enableActionsAfterScroll];
    }
    @catch (NSException *exception) {
        DLog(@"Exception after scrolling: %@", exception);
    }
}

#pragma mark - NewsTileDelegate methods

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

#pragma mark - IBAction methods

- (void)changeNewsContentTapped:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a search query below:" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Load News", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)leftActionTapped:(id)sender {
    int currentTileIndex = [self currentTileIndex];
    UIView *view = [self.scrollView viewWithTag:currentTileIndex + 100];
    if ([view isKindOfClass:[NewsTile class]]) {
        NewsTile *tile = (NewsTile *)view;
        [self shareText:tile.news.webTitle andImage:nil andUrl:tile.news.fullURL];
    } else {
        DLog(@"Error finding the current tile view");
    }
}

- (void)centerActionTapped:(id)sender {
    int currentTileIndex = [self currentTileIndex];
    UIView *view = [self.scrollView viewWithTag:currentTileIndex + 100];
    if ([view isKindOfClass:[NewsTile class]]) {
        [self tileTapped:(NewsTile *)view];
    } else {
        DLog(@"Error finding the current tile view");
    }
}

- (void)rightActionTapped:(id)sender {
    [SVProgressHUD showErrorWithStatus:@"Not yet implemented."];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // If load news button is tapped
    if (buttonIndex == 1) {
        UITextField *textfield = [alertView textFieldAtIndex: 0];
        NSString *searchQuery = textfield.text;
        [self loadNewsWithQuery:searchQuery];
    }
}

@end
