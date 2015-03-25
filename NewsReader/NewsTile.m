//
//  NewsTile.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/22/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "NewsTile.h"
#import "Macros.h"

#define TILE_CORNER_SIZE 15
#define TILE_DEFAULT_COLOR 0xF4F4F4
#define TILE_CURRENT_COLOR 0xFFFFFF
#define TILE_TITLE_COLOR 0x002261

#define SCALE_FACTOR_WIDTH 3.8
#define SCALE_FACTOR_HEIGHT 850.0
#define SCALE_CORRECTION 1.4
#define ROTATION_FACTOR 1000.0

#define SEGMENT_DETAIL_HEIGHT_DIFF 130.0

@interface NewsTile ()

@property (nonatomic, strong) UILabel *newsTitleLabel;

@end

@implementation NewsTile

- (id)initWithFrame:(CGRect)frame news:(News *)news {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _news = news;
        
        self.backgroundColor = HEXCOLOR(TILE_DEFAULT_COLOR);
        self.layer.cornerRadius = TILE_CORNER_SIZE;
        _initialFrame = frame;
        
        double leftMargin = 15.f;
        double topMargin = 15.f;
        
        _newsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, topMargin, frame.size.width - leftMargin * 2, topMargin)];
        _newsTitleLabel.textColor = HEXCOLOR(TILE_TITLE_COLOR);
        _newsTitleLabel.backgroundColor = [UIColor clearColor];
        _newsTitleLabel.text = news.webTitle;
        _newsTitleLabel.opaque = NO;
        _newsTitleLabel.textAlignment = NSTextAlignmentLeft;
        _newsTitleLabel.minimumScaleFactor = 2;
        _newsTitleLabel.autoresizesSubviews = YES;
        _newsTitleLabel.numberOfLines = 0;
        _newsTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.f];
        [_newsTitleLabel sizeToFit];
        
        [self addSubview:_newsTitleLabel];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.delegate) {
        
        // Calculate the scale for the tile based on its position
        float diff = [self.delegate viewOffsetForScaling:self];
        
        float scaleWidth = SCALE_CORRECTION - (fabsf(diff) / self.initialFrame.size.width / SCALE_FACTOR_WIDTH);
        float scaleHeight = 1.0f - (fabsf(diff) / SCALE_FACTOR_HEIGHT);
        float rotation = diff / self.initialFrame.size.width / ROTATION_FACTOR;
        
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = rotation;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 45.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        
        CATransform3D scaleTransform = CATransform3DMakeScale(scaleWidth, scaleHeight, 1.0);
        
        CATransform3D finalTransform = CATransform3DConcat(scaleTransform, rotationAndPerspectiveTransform);

        self.layer.transform = finalTransform;
    }
}

- (void)setNews:(News *)news {
    _news = news;
    self.newsTitleLabel.text = news.webTitle;
}

@end
