//
//  News.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/23/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "News.h"
#import "APIClient.h"

@implementation News

#pragma mark - Initializers

- (instancetype)initWithAPIURL:(NSString*)apiURL newsID:(NSString *)newsID sectionID:(NSString *)sectionID sectionName:(NSString *)sectionName publicationDate:(NSDate *)publicationDate webTitle:(NSString *)webTitle webURL:(NSString *)webURL {
    
    self = [super init];
    
    if (self) {
        _apiURL = [apiURL copy];
        _newsID = [newsID copy];
        _sectionID = [sectionID copy];
        _sectionName = [sectionName copy];
        _webPulicationDate = [publicationDate copy];
        _webTitle = [webTitle copy];
        _webURL = [newsID copy];
    }
    
    return self;
}

#pragma mark - Get Data Methods

+ (void)getNewsBySectionName:(NSString *)keyword block:(NewsResult)closure {
    
}

+ (void)getNewsByKeyword:(NSString *)keyword block:(NewsResult)closure {

    NSString *requestPath = [NSString stringWithFormat:@"search?api-key=%@&q=%@&fields=headline,trailText,thumbnail&order-by=newest", [APIClient sharedInstance].APIKey, keyword];
    
    // Make the API call
    [[APIClient sharedInstance] GET:requestPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"Request URL: %@", operation.request.URL);
        
        // Parse the API call results
        NSError *error;
        NSArray *news = [self parseNewsResponse:responseObject error:&error];
        NSLog(@"Response object: %@", responseObject);
        
        // Depending on what the error is we may decide to disregard the data altogether or still use it despite errors
        if (error) {
            if (closure != NULL) {
                closure(error, nil);
            }
        } else {
            if (closure != NULL) {
                closure(nil, @{@"news": news });
            }
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error while getting news by keyword: %@", [error localizedDescription]);
        if (closure != NULL) {
            closure(error, nil);
        }
    }];
}

#pragma mark - Parse Data Methods

+ (NSArray *)parseNewsResponse:(NSDictionary *)newsResponse error:(NSError **)parseError {
    
    NSMutableArray *news = [[NSMutableArray alloc] init];
    
    NSDictionary *newsItems = newsResponse[@"response"][@"results"];
    for (NSDictionary *newsItem in newsItems) {
        
        // TO DO: Error checking, and error setting if these values are missing etc.
        // TO DO: Make constants for the parsing keys
        // TO DO: Parse additional fields
        NSString *apiUrl = [newsItem objectForKey:@"apiUrl"];
        NSString *newsId = [newsItem objectForKey:@"id"];
        NSString *sectionId = [newsItem objectForKey:@"sectionId"];
        NSString *sectionName = [newsItem objectForKey:@"sectionName"];
        NSString *publicationDate = [newsItem objectForKey:@"webPublicationDate"];
        NSString *webTitle = [newsItem objectForKey:@"webTitle"];
        NSString *webUrl = [newsItem objectForKey:@"webUrl"];
        
        // TO DO: Only if the values are all present, add the object.
        News *newsObject = [[News alloc] initWithAPIURL:apiUrl
                                                 newsID:newsId
                                              sectionID:sectionId
                                            sectionName:sectionName
                                        publicationDate:nil
                                               webTitle:webTitle
                                                 webURL:webUrl];
        
        [news addObject:newsObject];
    }
    
    return [NSArray arrayWithArray:news];
}

@end
