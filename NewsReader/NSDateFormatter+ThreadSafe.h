//
//  NSDateFormatter+ThreadSafe.h
//  Skate
//
//  Created by Serdar Karatekin on 12/16/13.
//  Copyright (c) 2013 Crispin Porter + Bogusky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (ThreadSafe)

+ (NSDateFormatter *)threadSafeDateFormatter;

@end
