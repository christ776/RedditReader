//
//  RRTableViewController.h
//  RedditReader
//
//  Created by Christian De Martino on 8/25/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHFacebookImageViewer.h"

@interface RRTableViewController : UITableViewController <MHFacebookImageViewerDatasource,UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *redditSearchBar;
@end
