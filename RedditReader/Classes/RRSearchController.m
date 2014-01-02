//
//  RRSearchController.m
//  RedditReader
//
//  Created by Christian De Martino on 12/28/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "RRSearchController.h"

@implementation RRSearchController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive: visible animated: animated];
    
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];
}


@end
