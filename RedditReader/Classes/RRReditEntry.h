//
//  RRReditEntry.h
//  RedditReader
//
//  Created by Christian De Martino on 8/24/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRReditEntry : NSObject

@property (nonatomic,strong) NSString *subreddit;
@property (nonatomic,strong) NSString *author;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSURL* url;
@property (nonatomic,strong) NSString* thumbnailURLString;
@property (nonatomic,strong) NSNumber* num_comments;
@property (nonatomic,assign) NSInteger ups;
@property (nonatomic,assign) NSInteger downs;
@property (nonatomic,strong) NSDate *creationDate;
@property (nonatomic,strong) NSString *redditId;
@property (nonatomic,strong) NSArray *comments;

@end
