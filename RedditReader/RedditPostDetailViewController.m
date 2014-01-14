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
    
}

-(void) viewDidAppear:(BOOL)animated {
    
    __block UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.center = self.view.center;
    [self.view addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    
    __weak RedditPostDetailViewController *bself = self;
    
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [bself.tableView beginUpdates];
                [bself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
                [bself.tableView endUpdates];
                [loadingIndicator stopAnimating];
                [loadingIndicator removeFromSuperview];
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // If things went bad, show an alert view
                UIAlertView *av = [[UIAlertView alloc]
                                   initWithTitle:@"Error"
                                   message:[err localizedDescription]
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
                [av show];
                 [loadingIndicator stopAnimating];
                [loadingIndicator removeFromSuperview];
            });
        }
    }];
}

#pragma UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.comments.count + 1; //Because of the redditEntry at the top.
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        return 0;
    }
    else {
        RRReditComment  *redditCommnent = [self.comments objectAtIndex:indexPath.row -1];
        return redditCommnent.depth;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    if (indexPath.row ==0)
    {
        RRReditEntryCellView *cell = [tableView dequeueReusableCellWithIdentifier:redditEntryCellIdentifier];
        cell.titleLabel.text = self.redditEntry.title;
        height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height;
    }
    else {
        RReditCommentsCellView *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        RRReditComment  *redditCommnent = [self.comments objectAtIndex:indexPath.row -1];
         cell.redditCommentsLabel.text = redditCommnent.body;
        
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height;
    }
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
        cell.authorLabel.text = redditCommnent.author;
        cell.commentDate.text = redditCommnent.commentDateStr;
        return cell;
    }
    
}


@end
