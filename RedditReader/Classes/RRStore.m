//
//  RRStore.m
//  RedditReader
//
//  Created by Christian De Martino on 8/24/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "RRStore.h"
#import "AFJSONRequestOperation.h"
#import "JSONParser.h"
#import "RRHTTPClient.h"
#import "AFJSONRequestOperation.h"

@interface RRStore ()

@end

@implementation RRStore

@synthesize lastRedditID = _lastRedditID;

+(RRStore*) sharedStore {
    
    static RRStore* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)fetchRedditFeed: (RedditRequestType) redditRequestType withCompletion:(void (^)(NSArray *obj, NSError *err))block {
    
    NSString *urlString = nil;
    
    switch (redditRequestType) {
        case Fetch_Latest:
        {
             urlString = TOP_REDDITS;
        }
        break;
        case Fetch_NextBatch:
        {
            // for example http://www.reddit.com/top.json?after=1l16cq will bring the next top 25 reddit entries
            // following the reddit whose id is "1l16cq"
            
            urlString = [NSString stringWithFormat:@"%@?after=%@",TOP_REDDITS,self.lastRedditID];
        }
            
        default:
            break;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[RRHTTPClient sharedClient] getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
           // DLog(@"Did finished loading data %@ ",responseObject);
            NSArray* reddits =  [[JSONParser sharedInstance] parseReddits:responseObject];
            
            if (block) {
                block(reddits, nil);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (block) {
                block(nil,error);
            }
        }];
    });
}

- (void)fetchRepliesForPost: (NSString*) redditId withCompletion:(void (^)(NSArray *obj, NSError *err))block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *urlString = [NSString stringWithFormat:COMMENTS_FOR_REDDIT, redditId];
        
        [[RRHTTPClient sharedClient] getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //DLog(@"Did finished loading data %@ ",responseObject);
            NSArray* reddits =  [[JSONParser sharedInstance] parseComments:[responseObject lastObject] withDepth:0];
            
            block(reddits, nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (block) {
                block(nil,error);
            }
        }];
    });
}

- (void)fetchSubRedditsWithCompletionBlock: (void (^) (NSArray* result)) success failure:(void (^)(NSError *error)) failureblock {
    
    [[RRHTTPClient sharedClient] getPath:TOP_SUBREDDITS parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray* reddits =  [[JSONParser sharedInstance] parseSubReddits:responseObject];
            success(reddits);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failureblock(error);
    }];
    
}

@end
