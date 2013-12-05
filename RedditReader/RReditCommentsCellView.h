//
//  RReditCommentsCellView.h
//  RedditReader
//
//  Created by Christian De Martino on 10/27/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RReditCommentsCellView : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *redditCommentsLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentDate;

@end
