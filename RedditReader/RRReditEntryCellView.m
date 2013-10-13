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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(self.imageView, self);
//        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[self.titleLabel]-[self.authorLabel]-(5)-|" options:0 metrics:nil views:viewsDictionary];
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
