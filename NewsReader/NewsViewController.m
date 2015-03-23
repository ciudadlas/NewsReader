//
//  ViewController.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/22/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "NewsViewController.h"
#import "Macros.h"

@interface NewsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *leftAction;
@property (weak, nonatomic) IBOutlet UIView *centerAction;
@property (weak, nonatomic) IBOutlet UIView *rightAction;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"egg_shell"]];
    self.view.backgroundColor = patternColor;
    
//    [self configActions];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This is called after the auto layout constraints of the view have been applied, which is what we need.
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Add 10 tiles
    for (int i = 0; i < 10; i++) {
        
        NewsTile *tile = [[NewsTile alloc] initWithFrame:CGRectMake(i*self.scrollView.frame.size.width + 10, 10,
                                                                    self.scrollView.bounds.size.width - 20, self.scrollView.bounds.size.height - 20)];
        tile.delegate = self;
        
        NSLog(@"%@", NSStringFromCGRect(self.scrollView.frame));
        [self.scrollView addSubview:tile];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 10, self.scrollView.frame.size.height);
}

#pragma mark - Helper Methods

// create the proper placement and perspective for the action menu segments
- (void)configActions {
    [self setAnchorPoint:CGPointMake(1.5, 0.5) forView:self.leftAction];
    [self setAnchorPoint:CGPointMake(-0.5,0.5) forView:self.rightAction];
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

- (float)relativeOffset
{
    float offset = self.scrollView.contentOffset.x;
    float contentSize = self.scrollView.contentSize.width;
    float width = self.scrollView.frame.size.width;
    
    // don't process when bouncing beyond the range of the scroll view
    // clamp offset value between first and last segment
    offset = clamp(offset, 0., contentSize - width);
    
    // now divide into the number of segments
    offset = fmodf(offset, width);
    
    return offset;
}

- (void)layoutActionMenuForOffset:(float)offset
{
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

- (float)transformRotation:(float)rotationAmount
{
    // map our rotation so it flips back down at the center point and the layer is never upside down
    float returnVal = rotationAmount >= 0.5 ? rotationAmount - 1 : rotationAmount;
    
    // because the layer has no height, it'll disappear for a moment at this value if we don't fix it
    returnVal = returnVal == -0.5 ? -0.4999 : returnVal;
    
    // mapping rotation to a true circular path
    returnVal = asinf(2 * returnVal) / M_PI * 2;
    
    return returnVal;
}

- (void)rotateAction:(UIView *)action byAmount:(float)amount
{
    CATransform3D rotationTransform = CATransform3DIdentity;
    
    rotationTransform.m33 = 0.0;
    rotationTransform.m34 = 0.005;
    rotationTransform = CATransform3DRotate(rotationTransform, amount * M_PI / 2, 1.0, 0.0, 0.0);
    
    CALayer *layer = action.layer;
    layer.transform = rotationTransform;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (UIView *newsTile in [scrollView subviews]) {
        [newsTile setNeedsLayout];
    }
    
    [self layoutActionMenuForOffset:[self relativeOffset]];
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

@end
