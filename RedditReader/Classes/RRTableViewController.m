//
//  RRTableViewController.m
//  RedditReader
//
//  Created by Christian De Martino on 8/25/13.
//  Copyright (c) 2013 Christian De Martino. All rights reserved.
//

#define maxSize CGSizeMake(200.0f, CGFLOAT_MAX)

#import "RRTableViewController.h"
#import "RRStore.h"
#import "RRReditEntryCellView.h"
#import "RRReditEntry.h"
#import "UIImageView+WebCache.h"
#import "NSDate+FormattingUtils.h"
#import "RedditPostDetailViewController.h"

@interface RRTableViewController ()

@property (nonatomic,strong) NSMutableArray *entries;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) NSMutableArray *cellHeights;

@end

@implementation RRTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.entries = [NSMutableArray array];
        self.cellHeights = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.entries = [NSMutableArray array];
        self.cellHeights = [NSMutableArray array];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.entries = [NSMutableArray array];
        self.cellHeights = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // [self.tableView registerNib:[UINib nibWithNibName:@"RedditEntryCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refreshControl addTarget:self
                  action:@selector(refreshView:)
                  forControlEvents:UIControlEventValueChanged];

    [self setupTableViewFooter];
    [self fetchTopReddits:Fetch_Latest];
}

#pragma UITableView DataSource methods

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MyIdentifier";
    RRReditEntryCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
    RRReditEntry *redditEntry = [self.entries objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = redditEntry.title;

    //cell.authorLabel.text = redditEntry.author;
    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.thumbnailView setImageWithURL:[NSURL URLWithString:redditEntry.thumbnailURLString]
                   placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    //cell.commentsLabel.text = [redditEntry.num_comments stringValue];
    //cell.creationTimeLabel.text = [NSDate displaytimeInterval:[redditEntry.creationDate timeIntervalSinceNow]];
    //[cell setNeedsUpdateConstraints];
    return cell;
}

#pragma UIRefreshControl methods

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self fetchTopReddits:Fetch_Latest];

    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [[self formatter] stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.entries count];
}

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
    RRReditEntry *redditEntry = [self.entries objectAtIndex:indexPath.row];
    cell.titleLabel.text = redditEntry.title;

    CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"RedditDetail"])
	{
		RedditPostDetailViewController *detailViewController = segue.destinationViewController;
		detailViewController.redditEntry =  [self.entries objectAtIndex:[ self.tableView indexPathForSelectedRow].row];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	}
}

-(void)setupTableViewFooter
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    footerView.backgroundColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Load More Reddits";
    
    //self.footerLabel = label;
    [footerView addSubview:label];
    
    // set up activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = CGPointMake(40, 22);
    self.activityIndicator.hidesWhenStopped = YES;
    
    [footerView addSubview:self.activityIndicator];
    
    self.tableView.tableFooterView = footerView;
}

#pragma private methods. Fetch the latest Reddit entries or bring the next batch.
- (void)fetchTopReddits:(RedditRequestType) requestType
{
    [self.activityIndicator startAnimating];
    [[RRStore sharedStore] fetchRedditFeed:requestType withCompletion:^(NSArray *obj, NSError *err) {
        
        // When the request completes, this block will be called.
        
        if (!err) {

            NSMutableArray *indexPaths = [NSMutableArray array];
            int currentAmountOfEntries = self.entries.count;
            for(int i= currentAmountOfEntries; i < obj.count + currentAmountOfEntries; i++)
            {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    
            }
            
            // If everything went ok reload the table.
            [self.entries addObjectsFromArray:obj];
            
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
        
         dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.activityIndicator stopAnimating];
        });

    }];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        // fetch next page of results
        [self fetchTopReddits:Fetch_NextBatch];
    }
}

- (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
         [formatter setDateFormat:@"MMM d, h:mm a"];
    });
    return formatter;
}

@end
