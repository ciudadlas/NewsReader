//
//  NSString+StripHTML.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/31/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "NSString+StripHTML.h"

@implementation NSString (StripHTML)

- (NSString *)stripHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end
