//
//  APIClient.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/25/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "APIClient.h"

static NSString *const APIKey = @"fj2uazcf5zp3hbfgw7xtnaad";
static NSString *const APIURLString = @"http://content.guardianapis.com";

@implementation APIClient

+ (APIClient *)sharedInstance {
    static APIClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:APIURLString]];
    });
    
    return sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (NSString *)APIKey {
    return APIKey;
}

- (NSMutableDictionary *)newsSearchQuerySharedParameters {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:APIKey forKey:@"api-key"];
    [dict setObject:@"headline,trailText,thumbnail" forKey:@"show-fields"];
    [dict setObject:@"newest" forKey:@"order-by"];
    
    return dict;
}

@end
