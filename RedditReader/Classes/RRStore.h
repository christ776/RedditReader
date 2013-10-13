//
//  RRStore.h
//  RedditReader
//
//  Created by Christian De Martino on 8/24/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

typedef NS_ENUM(NSUInteger, RedditRequestType) {Fetch_NextBatch, Fetch_Latest} ;

#import <Foundation/Foundation.h>

@interface RRStore : NSObject

@property (nonatomic,strong) NSString *lastRedditID;

+(RRStore*) sharedStore;

- (void)fetchRedditFeed: (RedditRequestType) redditRequestType withCompletion:(void (^)(NSArray *obj, NSError *err))block;

@end
