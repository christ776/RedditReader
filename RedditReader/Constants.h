//
//  Constants.h
//  RedditReader
//
//  Created by Christian De Martino on 8/24/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#ifndef RedditReader_Constants_h
#define RedditReader_Constants_h

#ifdef DEBUG_MODE
#define DLog( s, ... ) NSLog( @"< %@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif

#define REDDIT_BASE_URL @"http://www.reddit.com/"
#define TOP_REDDITS @"top.json"
#define COMMENTS_FOR_REDDIT @"comments/%@.json"

#endif
