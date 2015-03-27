//
//  ActionMenuView.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/26/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "ActionMenuView.h"
#import "Macros.h"

@interface ActionMenuView()

@property (weak, nonatomic) IBOutlet UIView *leftAction;
@property (weak, nonatomic) IBOutlet UIView *centerAction;
@property (weak, nonatomic) IBOutlet UIView *rightAction;

@end

@implementation ActionMenuView

- (void)setup {
    
#warning TO DO: Look into why this is happening and finding a fix
    // These are displacing the menu buttons, so avoiding for now.
    //    [self setAnchorPoint:CGPointMake(1.5, 0.5) forView:self.leftAction];
    //    [self setAnchorPoint:CGPointMake(-0.5, 0.5) forView:self.rightAction];
    
    // Config left action
    UITapGestureRecognizer *tapLeft = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftActionTapped:)];
    tapLeft.numberOfTapsRequired = 1;
    tapLeft.numberOfTouchesRequired = 1;
    [self.leftAction addGestureRecognizer:tapLeft];
    
    // Config center action
    UITapGestureRecognizer *tapCenter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerActionTapped:)];
    tapCenter.numberOfTapsRequired = 1;
    tapCenter.numberOfTouchesRequired = 1;
    [self.centerAction addGestureRecognizer:tapCenter];
    
    // Config right action
    UITapGestureRecognizer *tapRight = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(rightActionTapped:)];
    tapRight.numberOfTapsRequired = 1;
    tapRight.numberOfTouchesRequired = 1;
    [self.rightAction addGestureRecognizer:tapRight];
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

- (void)updateActionMenuLayoutWithScrollViewOffset:(float)offset scrollView:(UIScrollView *)scrollView {
    
    // we're splitting the offset into three equally-spaced animations
    // Timeline:      |----|----|----|----|----|
    // Left action:   |--------------|
    // Center action:      |--------------|
    // Right action:            |--------------|
    
    float maxOffset = scrollView.frame.size.width;
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
    // Without this, tap gesture recognizers on these views stop working due to the rotation.
    self.leftAction.layer.transform = CATransform3DIdentity;
    self.centerAction.layer.transform = CATransform3DIdentity;
    self.rightAction.layer.transform = CATransform3DIdentity;
}

#pragma mark - Button Tap Methods

- (void)leftActionTapped:(id)sender {
    [self.delegate leftActionButtonTapped:self];
}

- (void)centerActionTapped:(id)sender {
    [self.delegate centerActionButtonTapped:self];
}

- (void)rightActionTapped:(id)sender {
    [self.delegate rightActionButtonTapped:self];
}

@end
