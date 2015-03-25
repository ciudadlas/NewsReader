//
//  APIClient.h
//  NewsReader
//
//  Created by Serdar Karatekin on 3/25/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface APIClient : AFHTTPRequestOperationManager

@property (nonatomic, strong, readonly) NSString *APIKey;

+ (APIClient *)sharedInstance;
- (instancetype)initWithBaseURL:(NSURL *)url;

@end
