//
//  RRSubRedditViewController.m
//  RedditReader
//
//  Created by Christian De Martino on 12/21/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "RRSubRedditViewController.h"
#import "RRStore.h"
#import "RRSubReddit.h"
#import "UIImageView+WebCache.h"

@interface RRSubRedditViewController ()

@property (nonatomic,strong) NSArray *subreddits;

@end

@implementation RRSubRedditViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.subreddits = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [[RRStore sharedStore] fetchSubRedditsWithCompletionBlock:^(NSArray *result) {
        self.subreddits = result;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.subreddits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SubredditCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RRSubReddit *subReddit = [self.subreddits objectAtIndex:indexPath.row];
    cell.textLabel.text = subReddit.title;
    if (![subReddit.thumbnailURLString isEqual:[NSNull null]]) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:subReddit.thumbnailURLString]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RRSubReddit *subReddit = [self.subreddits objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SubRedditChange" object:nil
                                                      userInfo:@{@"subreddit":subReddit}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeLeftPanel" object:nil];
}


@end
