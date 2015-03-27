//
//  NSDateFormatter+ThreadSafe.h
//  Skate
//
//  Created by Serdar Karatekin on 3/27/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (ThreadSafe)

+ (NSDateFormatter *)threadSafeDateFormatter;

@end
