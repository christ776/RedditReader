//
//  RRSidePanelController.m
//  RedditReader
//
//  Created by Christian De Martino on 12/21/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "RRSidePanelController.h"
#import "UIImageView+WebCache.h"
#import "RRSubReddit.h"

@interface RRSidePanelController ()

@end

@implementation RRSidePanelController

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeLeftPanel) name:@"closeLeftPanel" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subRedditHasChanged:) name:@"SubRedditChange" object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeLeftPanel" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SubRedditChange" object:nil];
}

-(void) closeLeftPanel {
    [self toggleLeftPanel:nil];
}

-(void) subRedditHasChanged:(NSNotification*) notification {
    
    RRSubReddit *subReddit = [notification.userInfo objectForKey:@"subreddit"];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    if (![subReddit.thumbnailURLString isEqual:[NSNull null]]) {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:subReddit.thumbnailURLString]];
        UIImageView *titleView =  [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
        [headerView addSubview:titleView];
    }
    
     UIFont * titleFont = [UIFont systemFontOfSize:17.];
    CGSize textSize = [subReddit.title sizeWithFont:titleFont];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, textSize.width, textSize.height)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:titleFont];
    [titleLabel setText:subReddit.title];
    [headerView addSubview:titleLabel];
    
    self.navigationItem.titleView = headerView;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) awakeFromNib
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"centerViewController"]];
//    [self setRightPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"rightViewController"]];
}

@end
