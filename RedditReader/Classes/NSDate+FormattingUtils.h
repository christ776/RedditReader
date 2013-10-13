//
//  NSDate+FormattingUtils.h
//  RedditReader
//
//  Created by Christian De Martino on 8/25/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FormattingUtils)

+(NSString*)displaytimeInterval:(NSTimeInterval)interval;

@end
