//
//  TileViewManager.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/26/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "TileScrollViewManager.h"
#import "NewsTileView.h"
#import "Macros.h"

@interface TileScrollViewManager() <NewsTileViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableSet *recycledTiles;
@property (strong, nonatomic) NSMutableSet *visibleTiles;

@property (nonatomic) int selectedTileIndex;

@end

@implementation TileScrollViewManager

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        _recycledTiles = [[NSMutableSet alloc] initWithObjects:nil];
        _visibleTiles = [[NSMutableSet alloc] initWithObjects:nil];
    }
    
    return self;
}

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
    for (NewsTileView *page in self.visibleTiles) {
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
        NewsTileView *tile = [self dequeueReusableTileView];
        CGRect tileFrame = CGRectMake(index*self.scrollView.frame.size.width + 10, 10,
                                      self.scrollView.bounds.size.width - 20, self.scrollView.bounds.size.height - 20);
        if (tile) {
            //            DLog(@"Re-using tile.");
            tile.news = news;
            tile.frame = tileFrame;
        } else {
            //            DLog(@"Creating new tile.");
            tile = [[NewsTileView alloc] initWithFrame:tileFrame news:news];
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
            for (NewsTileView *tile in self.visibleTiles) {
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

- (NewsTileView *)dequeueReusableTileView {
    NewsTileView *tileView = [self.recycledTiles anyObject];
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

- (NewsTileView *)currentTileView {
    int currentTileIndex = [self currentTileIndex];
    UIView *view = [self.scrollView viewWithTag:[self getTagFromIndex:currentTileIndex]];
    
    if (view && [view isKindOfClass:[NewsTileView class]]) {
        return (NewsTileView *)view;
    } else {
        DLog(@"Error finding the current tile view.");
        return nil;
    }
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

#pragma mark - NewsTileDelegate Methods

- (float)viewOffsetForScaling:(NewsTileView *)tile {
    
    float diff = (self.scrollView.contentOffset.x + (tile.frame.size.width / 2)) - tile.center.x;
    
    if (diff > tile.initialFrame.size.width) {
        diff = tile.initialFrame.size.width;
    }
    else if ( diff < -tile.initialFrame.size.width) {
        diff = -tile.initialFrame.size.width;
    }
    
    return diff;
}

- (void)tileTapped:(NewsTileView *)tile {
    [self.delegate tileTapped:tile];
}

@end
