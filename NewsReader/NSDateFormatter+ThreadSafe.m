//
//  NSDateFormatter+ThreadSafe.m
//  Skate
//
//  Created by Serdar Karatekin on 3/27/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "NSDateFormatter+ThreadSafe.h"

@implementation NSDateFormatter (ThreadSafe)

NSString *const CachedDateFormatterKey = @"CachedDateFormatterKey";

// Taken from https://coderwall.com/p/yjnkwg
// There may be more efficient ways to do this with the C functions: https://developer.apple.com/library/mac/documentation/cocoa/conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
+ (NSDateFormatter *)threadSafeDateFormatter {
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = [threadDictionary objectForKey:CachedDateFormatterKey];
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        [threadDictionary setObject:dateFormatter forKey:CachedDateFormatterKey];
    }
    return dateFormatter;
}

@end
