//
//  NSDate+FormattingUtils.m
//  RedditReader
//
//  Created by Christian De Martino on 8/25/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "NSDate+FormattingUtils.h"

@implementation NSDate (FormattingUtils)

+(NSString*)displaytimeInterval:(NSTimeInterval)interval
{
    int minutes  = abs(((int)interval/60)%60);
	int hours = abs(interval)/3600;
	int days = abs(interval)/(3600*24);
    
    NSString * tag = minutes > 1 ? [NSString stringWithFormat:NSLocalizedString(@"minutes_plural", nil), minutes] : NSLocalizedString(@"minutes", nil);
	
	if(days > 0) {
		tag = days > 1 ? [NSString stringWithFormat:NSLocalizedString(@"days_plural",nil), days] : NSLocalizedString(@"days",nil);
	}
	else if (hours > 0){
		tag = hours > 1 ? [NSString stringWithFormat:NSLocalizedString(@"hours_plural",nil), hours] : NSLocalizedString(@"hours",nil);
	}
	else if(minutes <= 0)
		tag = NSLocalizedString(@"moment",nil);
    
    return tag;
}

@end
