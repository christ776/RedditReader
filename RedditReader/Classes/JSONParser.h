//
//  JSONParser.h
//  RedditReader
//
//  Created by Christian De Martino on 8/24/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONParser : NSObject

+(JSONParser*) sharedInstance;

-(NSArray*) parseReddits :(NSDictionary*) redditData;
-(NSArray*) parseComments : (NSDictionary*) commentsData;

@end
