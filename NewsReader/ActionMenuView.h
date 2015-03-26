//
//  ActionMenuView.h
//  NewsReader
//
//  Created by Serdar Karatekin on 3/26/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ActionMenuView;

@protocol ActionMenuViewDelegate <NSObject>

@optional
- (void)leftActionButtonTapped:(ActionMenuView *)view;
- (void)centerActionButtonTapped:(ActionMenuView *)view;
- (void)rightActionButtonTapped:(ActionMenuView *)view;

@end

@interface ActionMenuView : UIView

@property (nonatomic, weak) id <ActionMenuViewDelegate> delegate;

- (void)configMenuActions;
- (void)updateActionMenuLayoutWithScrollViewOffset:(float)offset scrollView:(UIScrollView *)scrollView;
- (void)enableActionsAfterScroll;

@end
