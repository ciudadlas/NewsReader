//
//  NewsTile.h
//  NewsReader
//
//  Created by Serdar Karatekin on 3/22/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewsTile;

@protocol NewsTileScalingDelegate <NSObject>

@required
- (float)viewOffsetForScaling:(NewsTile *)tile;

@end

@interface NewsTile : UIView

@property (nonatomic) CGRect initialFrame;
@property (nonatomic, weak) id <NewsTileScalingDelegate> delegate;

@end
