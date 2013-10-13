//
//  RRHTTPClient.h
//  RedditReader
//
//  Created by Christian De Martino on 8/27/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "AFHTTPClient.h"

@interface RRHTTPClient : AFHTTPClient

+ (RRHTTPClient *)sharedClient;

@end
