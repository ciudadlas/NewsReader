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

@property (nonatomic, copy, readonly) NSString *apiURL;
@property (nonatomic, copy, readonly) NSString *newsID;
@property (nonatomic, copy, readonly) NSString *sectionID;
@property (nonatomic, copy, readonly) NSString *sectionName;
@property (nonatomic, copy, readonly) NSDate *webPulicationDate;
@property (nonatomic, copy, readonly) NSString *webTitle;
@property (nonatomic, copy, readonly) NSString *webURL;
@property (nonatomic, copy, readonly) NSString *summaryText;
@property (nonatomic, copy, readonly) NSString *thumbnailURL;
@property (nonatomic, readonly) NSURL *fullURL;

- (instancetype)initWithAPIURL:(NSString*)apiURL newsID:(NSString *)newsID sectionID:(NSString *)sectionID sectionName:(NSString *)sectionName publicationDate:(NSDate *)publicationDate webTitle:(NSString *)webTitle webURL:(NSString *)webURL thumbnailURL:(NSString *)thumbnailURL newsSummary:(NSString *)newsSummary;

+ (void)getNewsByKeyword:(NSString *)keyword block:(NewsResult)closure;

@end
