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

- (instancetype)initWithAPIURL:(NSString*)apiURL newsID:(NSString *)newsID sectionID:(NSString *)sectionID sectionName:(NSString *)sectionName publicationDate:(NSDate *)publicationDate webTitle:(NSString *)webTitle webURL:(NSString *)webURL thumbnailURL:(NSString *)thumbnailURL newsSummary:(NSString *)newsSummary {
    
    self = [super init];
    
    if (self) {
        _apiURL = [apiURL copy];
        _newsID = [newsID copy];
        _sectionID = [sectionID copy];
        _sectionName = [sectionName copy];
        _webPulicationDate = [publicationDate copy];
        _webTitle = [webTitle copy];
        _webURL = [newsID copy];
        _thumbnailURL = [thumbnailURL copy];
        _summaryText = [newsSummary copy];
    }
    
    return self;
}

#pragma mark - Get Data Methods

+ (void)getNewsBySectionName:(NSString *)keyword block:(NewsResult)closure {
#warning TO DO: Implement or delete
}

+ (void)getNewsByKeyword:(NSString *)keyword block:(NewsResult)closure {

    NSString *requestPath = [NSString stringWithFormat:@"search?api-key=%@&q=%@&show-fields=headline,trailText,thumbnail&order-by=newest", [APIClient sharedInstance].APIKey, keyword];
    
    // Make the API call
    [[APIClient sharedInstance] GET:requestPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"Request URL: %@", operation.request.URL);
        
        // Parse the API call results
        NSError *error;
        NSArray *news = [self parseNewsResponse:responseObject error:&error];
//        NSLog(@"Response object: %@", responseObject);
        
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDictionary *newsItems = newsResponse[@"response"][@"results"];
    for (NSDictionary *newsItem in newsItems) {
        
#warning TO DO: Error checking, and error setting if these values are missing etc.
#warning TO DO: Make constants for the parsing keys
        NSString *apiUrl = [newsItem objectForKey:@"apiUrl"];
        NSString *newsId = [newsItem objectForKey:@"id"];
        NSString *sectionId = [newsItem objectForKey:@"sectionId"];
        NSString *sectionName = [newsItem objectForKey:@"sectionName"];
        NSDate *publicationDate = [dateFormatter dateFromString:[newsItem objectForKey:@"webPublicationDate"]];
        NSString *webTitle = [newsItem objectForKey:@"webTitle"];
        NSString *webUrl = [newsItem objectForKey:@"webUrl"];
        
        NSString *thumbnailURL = nil;
        NSString *newsSummary = nil;
        
        NSDictionary *fields = [newsItem objectForKey:@"fields"];
        if (fields) {
            thumbnailURL = [fields objectForKey:@"thumbnail"];
            
            // It looks like that the API can return random <br> strings for the trailText field. Getting rid of those here.
            newsSummary = [[fields objectForKey:@"trailText"] stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        }
        
#warning TO DO: Only if the values are all present, add the object.
        News *newsObject = [[News alloc] initWithAPIURL:apiUrl
                                                 newsID:newsId
                                              sectionID:sectionId
                                            sectionName:sectionName
                                        publicationDate:publicationDate
                                               webTitle:webTitle
                                                 webURL:webUrl
                                           thumbnailURL:thumbnailURL
                                            newsSummary:newsSummary];
        
        [news addObject:newsObject];
    }
    
    return [NSArray arrayWithArray:news];
}

#pragma mark - Helpers

- (NSURL *)fullURL {
    if (self.webURL) {
        NSString *fullURLString = [NSString stringWithFormat:@"http://www.theguardian.com/%@", self.webURL];
        return [NSURL URLWithString:fullURLString];
    } else {
        return nil;
    }
}

@end
