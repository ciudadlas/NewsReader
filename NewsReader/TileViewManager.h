//
//  TileViewManager.h
//  NewsReader
//
//  Created by Serdar Karatekin on 3/26/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NewsTileView.h"

@protocol TileViewManagerDelegate <NSObject>

@optional
- (void)tileTapped:(NewsTileView *)tile;

@end

@interface TileViewManager : NSObject

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;
- (void)clearScrollView;
- (void)addTileWithIndex:(int)index;
- (void)repositionTiles;
- (float)relativeOffset;
- (int)currentTileIndex;
- (int)getArrayIndexFromTileViewTag:(int)tag;
- (int)getTagFromIndex:(int)index;

@property (strong, nonatomic) NSArray *newsItems;
@property (weak, nonatomic) id <TileViewManagerDelegate> delegate;

@end
