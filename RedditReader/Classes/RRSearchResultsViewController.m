//
//  RRSearchResultsViewController.m
//  RedditReader
//
//  Created by Christian De Martino on 1/4/14.
//  Copyright (c) 2014 Christian De Martino. All rights reserved.
//

#import "RRSearchResultsViewController.h"
#import "RRReditEntryCellView.h"
#import "RRReditEntry.h"
#import "UIImageView+WebCache.h"
#import "NSDate+FormattingUtils.h"
#import "RedditPostDetailViewController.h"

@interface RRSearchResultsViewController ()

@end

@implementation RRSearchResultsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.searchresults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue a cell for the particular layout required (you will likely need to substitute
    // the reuse identifier dynamically at runtime, instead of a static string as below).
    // Note that this method will init and return a new cell if there isn't one available in the reuse pool,
    // so either way after this line of code you will have a cell with the correct constraints ready to go.
    RRReditEntryCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    // Configure the cell with content for the given indexPath, for example:
    // cell.textLabel.text = someTextForThisCell;
    // ...
    RRReditEntry *redditEntry = [self.searchresults objectAtIndex:indexPath.row];
    cell.titleLabel.text = redditEntry.title;
    
    CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchresults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MyIdentifier";
    RRReditEntryCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RRReditEntry *redditEntry = [self.searchresults objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = redditEntry.title;
    
    cell.authorLabel.text = redditEntry.author;
    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.thumbnailView setImageWithURL:[NSURL URLWithString:redditEntry.thumbnailURLString]
                       placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    cell.commentsLabel.text = [redditEntry.num_comments stringValue];
    cell.creationTimeLabel.text = [NSDate displaytimeInterval:[redditEntry.creationDate timeIntervalSinceNow]];

    cell.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"RedditDetail"])
	{
		RedditPostDetailViewController *detailViewController = segue.destinationViewController;
		detailViewController.redditEntry =  [self.searchresults objectAtIndex:[ self.tableView indexPathForSelectedRow].row];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	}
}

@end
