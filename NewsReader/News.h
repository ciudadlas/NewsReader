//
//  News.h
//  NewsReader
//
//  Created by Serdar Karatekin on 3/23/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NewsResult)(NSError *error, NSDictionary *repsonse);

@interface News : NSObject

@property (copy, nonatomic, readonly) NSString *apiURL;
@property (copy, nonatomic, readonly) NSString *newsID;
@property (copy, nonatomic, readonly) NSString *sectionID;
@property (copy, nonatomic, readonly) NSString *sectionName;
@property (copy, nonatomic, readonly) NSDate *webPulicationDate;
@property (copy, nonatomic, readonly) NSString *webTitle;
@property (copy, nonatomic, readonly) NSString *webURL;
@property (copy, nonatomic, readonly) NSString *summaryText;
@property (copy, nonatomic, readonly) NSString *thumbnailURL;
@property (copy, nonatomic, readonly) NSURL *fullURL;

- (instancetype)initWithAPIURL:(NSString*)apiURL newsID:(NSString *)newsID sectionID:(NSString *)sectionID sectionName:(NSString *)sectionName publicationDate:(NSDate *)publicationDate webTitle:(NSString *)webTitle webURL:(NSString *)webURL thumbnailURL:(NSString *)thumbnailURL newsSummary:(NSString *)newsSummary;

+ (void)getNewsByKeyword:(NSString *)keyword block:(NewsResult)closure;

@end
