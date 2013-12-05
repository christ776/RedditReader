//
//  RRReditComment.h
//  RedditReader
//
//  Created by Christian De Martino on 10/20/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRReditComment : NSObject

@property (nonatomic,strong) NSString *body;
@property (nonatomic,unsafe_unretained) int depth;
@property (nonatomic,strong) NSArray *responses;
@property (nonatomic,strong) NSString *author;
@property (nonatomic,strong) NSString *commentDateStr;

@end
