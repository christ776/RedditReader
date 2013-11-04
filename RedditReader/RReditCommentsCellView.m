//
//  RReditCommentsCellView.m
//  RedditReader
//
//  Created by Christian De Martino on 10/27/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "RReditCommentsCellView.h"

@implementation RReditCommentsCellView

@synthesize redditCommentsLabel = _redditCommentsLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    self.redditCommentsLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
