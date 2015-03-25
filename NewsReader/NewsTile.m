//
//  NewsTile.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/22/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "NewsTile.h"
#import "Macros.h"
#import "UIImageView+AFNetworking.h"

#define TILE_CORNER_SIZE 15
#define TILE_DEFAULT_COLOR 0xF4F4F4
#define TILE_TITLE_COLOR 0x002261

#define SCALE_FACTOR_WIDTH 3.8
#define SCALE_FACTOR_HEIGHT 850.0
#define SCALE_CORRECTION 1.4
#define ROTATION_FACTOR 1000.0

#define SEGMENT_DETAIL_HEIGHT_DIFF 130.0

@interface NewsTile ()

@property (nonatomic, strong) UILabel *newsTitleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UITextView *summaryTextView;

@end

@implementation NewsTile

- (id)initWithFrame:(CGRect)frame news:(News *)news {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _news = news;
        
        self.backgroundColor = HEXCOLOR(TILE_DEFAULT_COLOR);
        self.layer.cornerRadius = TILE_CORNER_SIZE;
        _initialFrame = frame;
        
        // 1. Title Label
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
        _newsTitleLabel.numberOfLines = 2;
        _newsTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.f];
        [_newsTitleLabel sizeToFit];
        [self addSubview:_newsTitleLabel];
        
        // 2. Date Label
        double dateLabelLeftMargin = 15.f;
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateLabelLeftMargin, _newsTitleLabel.frame.size.height + _newsTitleLabel.frame.origin.y, frame.size.width - leftMargin * 2, topMargin)];
        _dateLabel.textColor = [UIColor grayColor];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.text = [news.webPulicationDate description]; // TO DO: Convert to a format like "2 hours ago", "1 day ago"
        _dateLabel.opaque = NO;
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.minimumScaleFactor = 2;
        _dateLabel.autoresizesSubviews = YES;
        _dateLabel.numberOfLines = 1;
        _dateLabel.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        [_dateLabel sizeToFit];
        [self addSubview:_dateLabel];
        
        // 3. Thumbnail Image
        double thumbnailLeftMargin = 15.f;
        double imageViewWidth = frame.size.width/2 - 2*thumbnailLeftMargin;
        _thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbnailLeftMargin, _dateLabel.frame.size.height + _dateLabel.frame.origin.y, imageViewWidth, imageViewWidth)];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit & UIViewContentModeTop;
        [_thumbnailImageView setImageWithURL:[NSURL URLWithString:news.thumbnailURL] placeholderImage:nil];
        [self addSubview:_thumbnailImageView];
        
        // 4. News Summary Label
        _summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(_thumbnailImageView.frame.origin.x + _thumbnailImageView.frame.size.width, _thumbnailImageView.frame.origin.y + 20, frame.size.width - _thumbnailImageView.frame.size.width - _thumbnailImageView.frame.origin.x , frame.size.height - _thumbnailImageView.frame.origin.y - 15)];
        _summaryTextView.text = news.summaryText;
        _summaryTextView.editable = NO;
        _summaryTextView.selectable = NO;
        _summaryTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:_summaryTextView];
        
        // 5. Tap Recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTile:)];
        [self addGestureRecognizer:tap];
        
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

- (void)tapTile:(UIGestureRecognizer *)gestureRecognizer {    
    [self.delegate tileTapped:self];
}

@end
