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
#import "RRSubReddit.h"

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
        
        NSDictionary *media = [redditData objectForKey:@"media"];
        if (![media isEqual: [NSNull null]]) {
            redditEntry.type = [media objectForKey:@"type"];
        }
        
        redditEntry.url = [NSURL URLWithString:[redditData objectForKey:@"url"]];
     
        redditEntry.creationDate = [NSDate dateWithTimeIntervalSince1970:[[redditData objectForKey:@"created"] doubleValue]];
        
        lastRedditID = [redditData objectForKey:@"name"];
    }
    
    [RRStore sharedStore].lastRedditID = lastRedditID;
    
    return reddits;
}

-(NSArray*) parseComments : (NSDictionary*) commentsData withDepth:(int) depth {
    
    NSMutableArray* comments = [NSMutableArray arrayWithCapacity:kInitialCapacity];
    NSArray *commentsInfo = [[commentsData objectForKey:@"data"] objectForKey:@"children"];
    
    
    for (NSDictionary *commentData in commentsInfo) {
        
        NSDictionary *redditData = [commentData objectForKey:@"data"];
        NSString *commentBody = [redditData objectForKey:@"body"];
        NSArray *commentReplies = [self parseCommentReplies:  [redditData objectForKey:@"replies"]
                                                  withDepth: depth];
        RRReditComment *redditComment = [[RRReditComment alloc] init];
        redditComment.body = commentBody;
        redditComment.depth = depth;
        redditComment.author =  [redditData objectForKey:@"author"];
        NSDate *created = [NSDate dateWithTimeIntervalSince1970:[[redditData objectForKey:@"created"] doubleValue]];
        redditComment.commentDateStr = [[self formatter] stringFromDate:created];
        [comments addObject:redditComment];
        [comments addObjectsFromArray:commentReplies];
    }
    
    return comments;
}

-(NSArray*) parseCommentReplies:(id) replies withDepth:(int) depth {
    
    if ([replies isKindOfClass:[NSDictionary class]]) {
        return [self parseComments:replies withDepth:depth+1];
    }
    else return nil;
}


-(NSArray*) parseSubReddits : (NSDictionary*) subReddits {
    
    NSMutableArray *subreddits = [NSMutableArray array];
    NSArray *subRedditsData = [[subReddits objectForKey:@"data"] objectForKey:@"children"];
    
    for (NSDictionary *subRedditData in subRedditsData) {
        
        NSDictionary *subRedditDictonary = [subRedditData objectForKey:@"data"];
        
        [self removeNSNulls:subRedditDictonary];
        
        RRSubReddit *subreddit = [[RRSubReddit alloc] init];
        subreddit.title = [subRedditDictonary objectForKey:@"display_name"];
        subreddit.thumbnailURLString = [subRedditDictonary objectForKey:@"header_img"];
        [subreddits addObject:subreddit];
    }
    return subreddits;
}


- (void) removeNSNulls:(NSDictionary*) dictionary {
    //Let's remove those keys for whose values are NSNull
    NSSet *nullSet = [dictionary keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ([obj isEqual:[NSNull null]]);
    }];
    
    [[dictionary mutableCopy] removeObjectsForKeys:[nullSet allObjects]];
}

- (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
    });
    return formatter;
}


@end
