//
//  RedditPostDetailViewController.m
//  RedditReader
//
//  Created by Christian De Martino on 10/20/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#import "RedditPostDetailViewController.h"
#import "RRReditEntryCellView.h"
#import "UIImageView+WebCache.h"
#import "RRStore.h"
#import "RRReditComment.h"
#import "RReditCommentsCellView.h"

static NSString *commentCellIdentifier = @"commentCell";
static NSString *redditEntryCellIdentifier = @"MyIdentifier";

@interface RedditPostDetailViewController ()

@property (nonatomic,strong) NSMutableArray *comments;

@end

@implementation RedditPostDetailViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.comments = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RedditEntryCell" bundle:nil] forCellReuseIdentifier:redditEntryCellIdentifier];
   // [self.tableView registerClass:[RReditCommentsCellView class] forCellReuseIdentifier:commentCellIdentifier];
    
	[[RRStore sharedStore] fetchRepliesForPost:self.redditEntry.redditId withCompletion:^(NSArray *obj, NSError *err) {
        if (!err) {
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            int currentAmountOfEntries = self.comments.count;
            for(int i= currentAmountOfEntries; i < obj.count + currentAmountOfEntries; i++)
            {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                
            }
            
            // If everything went ok reload the table.
            [self.comments addObjectsFromArray:obj];
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [self.tableView endUpdates];
            
        } else {
            
            // If things went bad, show an alert view
            UIAlertView *av = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:[err localizedDescription]
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
            [av show];
        }
    }];
}

#pragma UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.comments.count + 1; //Because of the redditEntry at the top.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.row ==0)
    {
        RRReditEntryCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];

        cell.titleLabel.text = self.redditEntry.title;
        height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    else {
        RReditCommentsCellView *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        RRReditComment  *redditCommnent = [self.comments objectAtIndex:indexPath.row -1];
        cell.redditCommentsLabel.text = redditCommnent.body;
        
        // force layout
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row ==0) {
        
        RRReditEntryCellView *cell = [tableView dequeueReusableCellWithIdentifier:redditEntryCellIdentifier];
        if (cell == nil) {
            cell = [[RRReditEntryCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:redditEntryCellIdentifier];
        }
        cell.titleLabel.text = self.redditEntry.title;
        
        //cell.authorLabel.text = redditEntry.author;
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.thumbnailView setImageWithURL:[NSURL URLWithString:self.redditEntry.thumbnailURLString]
                           placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        return cell;
    }
    else {
        RReditCommentsCellView *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        RRReditComment  *redditCommnent = [self.comments objectAtIndex:indexPath.row -1];
        cell.redditCommentsLabel.text = redditCommnent.body;
        return cell;
    }
    
}


@end