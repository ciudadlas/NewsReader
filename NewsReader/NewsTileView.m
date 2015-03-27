//
//  NewsTileView.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/22/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "NewsTileView.h"
#import "Macros.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+DateTools.h"

#define TILE_CORNER_SIZE 15
#define TILE_DEFAULT_COLOR 0xF4F4F4
#define TILE_TITLE_COLOR 0x002261

#define SCALE_FACTOR_WIDTH 3.8
#define SCALE_FACTOR_HEIGHT 850.0
#define SCALE_CORRECTION 1.4
#define ROTATION_FACTOR 1000.0

static int const StandardMargin = 15;

@interface NewsTileView ()

@property (strong, nonatomic) UILabel *newsTitleLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIImageView *thumbnailImageView;
@property (strong, nonatomic) UITextView *summaryTextView;

@end

@implementation NewsTileView

- (id)initWithFrame:(CGRect)frame news:(News *)news {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _news = news;
        _initialFrame = frame;
        [self setupView];
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
    
    [self resetView];
    [self setupTitleLabel];
    [self setupDateLabel];
    [self setupThumbnailImage];
    [self setupSummaryTextView];
}

- (void)tapTile:(UIGestureRecognizer *)gestureRecognizer {
    [self.delegate tileTapped:self];
}

#pragma mark - View Setup Helpers

- (void)setupView {
    self.backgroundColor = HEXCOLOR(TILE_DEFAULT_COLOR);
    self.layer.cornerRadius = TILE_CORNER_SIZE;
    self.layer.borderColor = HEXCOLOR(TILE_TITLE_COLOR).CGColor;
    self.layer.borderWidth = 2;
    
    [self setupTitleLabel];
    [self setupDateLabel];
    [self setupThumbnailImage];
    [self setupSummaryTextView];
    [self setupGestureRecognizer];
}

- (void)resetView {
    self.thumbnailImageView.image = nil;
    self.dateLabel.text = nil;
    self.newsTitleLabel.text = nil;
    self.summaryTextView.text = nil;
}

- (void)setupTitleLabel {
    
    CGRect viewFrame = CGRectMake(StandardMargin, StandardMargin,
                                  self.initialFrame.size.width - StandardMargin * 2, StandardMargin);
    
    if (!_newsTitleLabel) {
        _newsTitleLabel = [[UILabel alloc] initWithFrame:viewFrame];
        _newsTitleLabel.textColor = HEXCOLOR(TILE_TITLE_COLOR);
        _newsTitleLabel.backgroundColor = [UIColor clearColor];
        _newsTitleLabel.opaque = NO;
        _newsTitleLabel.textAlignment = NSTextAlignmentLeft;
        _newsTitleLabel.minimumScaleFactor = 2;
        _newsTitleLabel.autoresizesSubviews = YES;
        _newsTitleLabel.numberOfLines = 2;
        _newsTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.f];
        [self addSubview:_newsTitleLabel];
    } else {
        _newsTitleLabel.frame = viewFrame;
    }
    
    _newsTitleLabel.text = self.news.webTitle;
    [_newsTitleLabel sizeToFit];
}

- (void)setupDateLabel {
    
    CGRect viewFrame = CGRectMake(StandardMargin, _newsTitleLabel.frame.size.height + _newsTitleLabel.frame.origin.y,
                                  self.initialFrame.size.width - StandardMargin * 2, StandardMargin);
    
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:viewFrame];
        _dateLabel.textColor = [UIColor grayColor];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.opaque = NO;
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.minimumScaleFactor = 2;
        _dateLabel.autoresizesSubviews = YES;
        _dateLabel.numberOfLines = 1;
        _dateLabel.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        [self addSubview:_dateLabel];
    } else {
        _dateLabel.frame = viewFrame;
    }
    
    _dateLabel.text = [self.news.webPulicationDate timeAgoSinceNow];
    [_dateLabel sizeToFit];
}

- (void)setupThumbnailImage {
    double imageViewWidth = self.initialFrame.size.width/2 - 2*StandardMargin;
    
    CGRect viewFrame = CGRectMake(StandardMargin, _dateLabel.frame.size.height + _dateLabel.frame.origin.y + StandardMargin,
                                  imageViewWidth, imageViewWidth);
    
    if (!_thumbnailImageView) {
        _thumbnailImageView = [[UIImageView alloc] initWithFrame:viewFrame];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit & UIViewContentModeTop;
        [self addSubview:_thumbnailImageView];
    } else {
        _thumbnailImageView.frame = viewFrame;
    }
    
    [_thumbnailImageView setImageWithURL:[NSURL URLWithString:self.news.thumbnailURL] placeholderImage:nil];
}

- (void)setupSummaryTextView {
    
    CGRect viewFrame = CGRectMake(self.initialFrame.size.width / 2, self.thumbnailImageView.frame.origin.y - StandardMargin,
                                  self.initialFrame.size.width / 2 - StandardMargin, self.initialFrame.size.height - self.thumbnailImageView.frame.origin.y - StandardMargin);
    
    if (!_summaryTextView) {
        _summaryTextView = [[UITextView alloc] initWithFrame:viewFrame];
        _summaryTextView.editable = NO;
        _summaryTextView.selectable = NO;
        _summaryTextView.scrollEnabled = NO;
        _summaryTextView.backgroundColor = [UIColor clearColor];
        _summaryTextView.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        [self addSubview:_summaryTextView];
    } else {
        _summaryTextView.frame = viewFrame;
    }
    
    _summaryTextView.text = self.news.summaryText;
}

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTile:)];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
}

@end
