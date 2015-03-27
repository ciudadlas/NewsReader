//
//  News.m
//  NewsReader
//
//  Created by Serdar Karatekin on 3/23/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "News.h"
#import "APIClient.h"
#import "Macros.h"
#import "NSDateFormatter+ThreadSafe.h"

static NSString *const ParseErrorDomain = @"com.serdarkaratakin.NewsReader.ParseErrorDomain";

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

+ (void)getNewsByKeyword:(NSString *)keyword block:(NewsResult)closure {
    
    NSMutableDictionary *sharedParameters = [[APIClient sharedInstance] newsSearchQuerySharedParameters];
    [sharedParameters setObject:keyword forKey:@"q"];

    // Make the API call
    [[APIClient sharedInstance] GET:@"search" parameters:sharedParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        DLog(@"Request URL: %@", operation.request.URL);
        
        // Parse the API call results
        NSError *error;
        NSArray *news = [self parseNewsResponse:responseObject error:&error];
        
        // Depending on what the error is during parsing, we may decide to disregard the data altogether or still use it despite errors.
        // In this case if there is any error, we are returning error back, regardless of what the error is.
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
        
        DLog(@"Error while getting news by keyword: %@", [error localizedDescription]);
        if (closure != NULL) {
            closure(error, nil);
        }
    }];
}

#pragma mark - Parse Data Methods

+ (NSArray *)parseNewsResponse:(NSDictionary *)newsResponse error:(NSError **)parseError {
    
    NSMutableArray *newsArray = [[NSMutableArray alloc] init];
    
    NSArray *newsItems = newsResponse[@"response"][@"results"];
    if (newsItems) {
        for (NSDictionary *newsItem in newsItems) {
            News *news = [self parseSingleNewsItem:newsItem];
            if (news) {
                [newsArray addObject:news];
            }
        }
    } else {
        if (parseError != NULL) {
            *parseError = [NSError errorWithDomain:ParseErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey: @"News items missing in API response."}];
        }
    }
    
    return [NSArray arrayWithArray:newsArray];
}

+ (News *)parseSingleNewsItem:(NSDictionary *)newsItem {
    
    News *returnValue = nil;

#warning TO DO: Make constants for the parsing keys
    NSString *apiUrl = [newsItem objectForKey:@"apiUrl"];
    NSString *newsId = [newsItem objectForKey:@"id"];
    NSString *sectionId = [newsItem objectForKey:@"sectionId"];
    NSString *sectionName = [newsItem objectForKey:@"sectionName"];
    NSDate *publicationDate = [[NSDateFormatter threadSafeDateFormatter] dateFromString:[newsItem objectForKey:@"webPublicationDate"]];
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
    
    if (apiUrl && newsId && sectionId && sectionName && publicationDate && webTitle && webUrl && thumbnailURL && newsSummary) {
        
        News *newsObject = [[News alloc] initWithAPIURL:apiUrl
                                                 newsID:newsId
                                              sectionID:sectionId
                                            sectionName:sectionName
                                        publicationDate:publicationDate
                                               webTitle:webTitle
                                                 webURL:webUrl
                                           thumbnailURL:thumbnailURL
                                            newsSummary:newsSummary];
        
        returnValue = newsObject;
        
    } else {
        DLog(@"Missing value during parsing of single news item.");
    }
    
    return returnValue;
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
