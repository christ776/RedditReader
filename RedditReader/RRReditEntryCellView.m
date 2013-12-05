//
//  RRReditEntryCellViewCell.m
//  RedditReader
//
//  Created by Christian De Martino on 8/24/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "RRReditEntryCellView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RRReditEntryCellView

@synthesize commentsLabel = _commentsLabel;
@synthesize titleLabel = _titleLabel;
@synthesize thumbnailView = _thumbnailView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(5,5,60,60);
    //self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.authorLabel.textColor = [UIColor blueColor];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
