//
//  RRReditEntryCellViewCell.h
//  RedditReader
//
//  Created by Christian De Martino on 8/24/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRReditEntryCellView : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *commentsLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (strong, nonatomic) IBOutlet UILabel *creationTimeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightConstraint;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic,unsafe_unretained) id<UIGestureRecognizerDelegate> delegate;
@end
