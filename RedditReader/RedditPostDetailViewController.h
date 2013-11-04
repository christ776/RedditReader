//
//  RedditPostDetailViewController.h
//  RedditReader
//
//  Created by Christian De Martino on 10/20/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRReditEntry.h"

@interface RedditPostDetailViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) RRReditEntry *redditEntry;

@end
