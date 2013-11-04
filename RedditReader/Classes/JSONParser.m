//
//  JSONParser.m
//  RedditReader
//
//  Created by Christian De Martino on 8/24/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#define kInitialCapacity 25

#import "JSONParser.h"
#import "RRReditEntry.h"
#import "RRStore.h"
#import "RRReditComment.h"

@implementation JSONParser

+(JSONParser*) sharedInstance
{    
    static JSONParser* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
    
}

-(NSArray*) parseReddits :(NSDictionary*) redditData {
    
    NSMutableArray* reddits = [NSMutableArray arrayWithCapacity:kInitialCapacity];
    NSArray *redditEntries = [[redditData objectForKey:@"data"] objectForKey:@"children"];
    NSString *lastRedditID = @"";
    
    for (NSDictionary * reddit in redditEntries) {
        RRReditEntry *redditEntry = [[RRReditEntry alloc] init];
       [reddits addObject:redditEntry];
        NSDictionary *redditData = [reddit objectForKey:@"data"];
        
        redditEntry.title = [redditData objectForKey:@"title"];
        redditEntry.author = [redditData objectForKey:@"author"];
        redditEntry.num_comments = [redditData objectForKey:@"num_comments"];
        redditEntry.thumbnailURLString  = [redditData objectForKey:@"thumbnail"];
        redditEntry.redditId = [redditData objectForKey:@"id"];
     
        redditEntry.creationDate = [NSDate dateWithTimeIntervalSince1970:[[redditData objectForKey:@"created"] doubleValue]];
        
        lastRedditID = [redditData objectForKey:@"name"];
    }
    
    [RRStore sharedStore].lastRedditID = lastRedditID;
    
    return reddits;
}

-(NSArray*) parseComments : (NSArray*) commentsData {
    
    
    NSMutableArray* comments = [NSMutableArray arrayWithCapacity:kInitialCapacity];
    NSArray *commentsInfo = [[[commentsData lastObject] objectForKey:@"data"] objectForKey:@"children"];
    
    
    for (NSDictionary *commentData in commentsInfo) {
        
        NSString *commentBody = [[commentData objectForKey:@"data"] objectForKey:@"body"];
        RRReditComment *redditComment = [[RRReditComment alloc] init];
        redditComment.body = commentBody;
        [comments addObject:redditComment];
    }
    
    return comments;
}

@end
