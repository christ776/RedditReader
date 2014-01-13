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
@property (nonatomic,strong) NSString *currentSubReddit;

+(RRStore*) sharedStore;

- (void)fetchRedditFeed: (RedditRequestType) redditRequestType withCompletion:(void (^)(NSArray *obj, NSError *err))block;
- (void)fetchRepliesForPost: (NSString*) redditId withCompletion:(void (^)(NSArray *obj, NSError *err))block;
- (void)fetchSubRedditsWithCompletionBlock: (void (^) (NSArray* result)) success failure:(void (^)(NSError *error)) failureblock;
- (void) fetchRedditFeedWithSorting:(RedditSorting) sorting inSubReddit:(NSString*) subReddit withCompletionBlock: (void (^) (NSArray* result)) success failure:(void (^)(NSError *error)) failureblock;

-(void) searchForRedditsMatchingKeyworkd:(NSString*) keyword inSubReddit:(NSString*) subreddit withSorting:(RedditSorting) sorting withCompletionBlock: (void (^) (NSArray* result)) success failure:(void (^)(NSError *error)) failureblock;


@end
