//
//  ViewController.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/22/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"egg_shell"]];
    self.view.backgroundColor = patternColor;
    
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

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (UIView *newsTile in [scrollView subviews]) {
        [newsTile setNeedsLayout];
    }
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
