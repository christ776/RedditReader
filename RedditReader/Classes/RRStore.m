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
    
    
    [[RRHTTPClient sharedClient] getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        DLog(@"Did finished loading data %@ ",responseObject);
        NSArray* reddits =  [[JSONParser sharedInstance] parseReddits:responseObject];
        
        if (block) {
            block(reddits, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (block) {
            block(nil,error);
        }
    }];
    
}

@end
