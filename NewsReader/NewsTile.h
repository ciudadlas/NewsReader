//
//  NewsTile.h
//  NewsReader
//
//  Created by Serdar Karatekin on 3/22/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News.h"
@class NewsTile;

@protocol NewsTileDelegate <NSObject>

@required
- (float)viewOffsetForScaling:(NewsTile *)tile;
- (void)tileTapped:(NewsTile *)tile;

@end

@interface NewsTile : UIView

- (id)initWithFrame:(CGRect)frame news:(News *)news;

@property (nonatomic) CGRect initialFrame;
@property (nonatomic, weak) id <NewsTileDelegate> delegate;
@property (nonatomic, strong) News *news;

@end
