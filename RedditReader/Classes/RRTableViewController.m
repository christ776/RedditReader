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
#import "RRSubReddit.h"
#import "RRSearchResultsViewController.h"
#import "EXPhotoViewer.h"

@interface RRTableViewController ()

@property (nonatomic,strong) NSMutableArray *entries;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) NSMutableArray *cellHeights;

@end

@implementation RRTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.entries = [NSMutableArray array];
        self.cellHeights = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subredditChanged:)
                                                     name:@"SubRedditChange" object:nil];
    }
    return self;
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SubRedditChange" object:nil];
}

-(void) subredditChanged:(NSNotification*) notification {
    
    RRSubReddit *subReddit = [notification.userInfo objectForKey:@"subreddit"];
    
    [[RRStore sharedStore] fetchRedditFeedWithSorting:TOP inSubReddit:subReddit.title withCompletionBlock:^(NSArray *result) {
        
        [self.entries removeAllObjects];
        // If everything went ok reload the table.
        [self.entries addObjectsFromArray:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.tableView reloadData];
        });
        
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // If things went bad, show an alert view
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                               message:error.description
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
            [av show];
        });
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

    cell.authorLabel.text = redditEntry.author;
    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.thumbnailView setImageWithURL:[NSURL URLWithString:redditEntry.thumbnailURLString]
                   placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    
    cell.commentsLabel.text = [redditEntry.num_comments stringValue];
    cell.creationTimeLabel.text = [NSDate displaytimeInterval:[redditEntry.creationDate timeIntervalSinceNow]];
    cell.delegate = self;
    
    return cell;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    CGPoint tapPosition = [pinchGestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapPosition];
    RRReditEntry *reddit = [self.entries objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:reddit.url];
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
    if ([segue.identifier isEqualToString:@"searchResults"])
	{
		RRSearchResultsViewController *searchResultsController = segue.destinationViewController;
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        
        __weak RRTableViewController *bself = self;
        [[RRStore sharedStore] searchForRedditsMatchingKeyworkd:self.redditSearchBar.text inSubReddit:[RRStore sharedStore].currentSubReddit withSorting:TOP withCompletionBlock:^(NSArray *result) {

            [searchResultsController.searchresults removeAllObjects];
            // If everything went ok reload the table.
            [searchResultsController.searchresults addObjectsFromArray:result];

            dispatch_async(dispatch_get_main_queue(), ^{

                [searchResultsController.tableView reloadData];
                searchResultsController.title = bself.redditSearchBar.text;  
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // If things went bad, show an alert view
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:error.description
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            });
        }];
        
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
        dispatch_async(dispatch_get_main_queue(), ^{
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
            
        } else
        {
            // If things went bad, show an alert view
            UIAlertView *av = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:[err localizedDescription]
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
            [av show];
        }
        
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
    if (scrollView.contentOffset.y > 0) {
        UISearchBar *searchBar = self.redditSearchBar;
        CGRect rect = searchBar.frame;
        rect.origin.y = MIN(0, scrollView.contentOffset.y);
        searchBar.frame = rect;
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

#pragma UISearchBar Delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.redditSearchBar resignFirstResponder];
    [self.view endEditing:YES];
    
    [self performSegueWithIdentifier:@"searchResults" sender:self];

}

- (IBAction)sortingFilterValueChanged:(id)sender {
    
    switch (self.filteredSortingControl.selectedSegmentIndex) {
        case 0:
            NSLog(@"5d selected. Index: %d", self.filteredSortingControl.selectedSegmentIndex);
            break;
        case 1:
            [self.filteredSortingControl setSelectedSegmentIndex:1];
            break;
        default:
            break;
    }
    
}
- (IBAction)zooThumbnail:(UIButton *)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];

    RRReditEntry *reddit = [self.entries objectAtIndex:indexPath.row];
    if (![reddit.type isEqualToString:@"youtube.com"]) {
        UIImageView *fullImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        __block UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 150, 50, 50)];
        progressLabel.text = @"0.0";
        progressLabel.textColor = [UIColor whiteColor];
        
        __weak UIImageView *_fullImage = fullImage;
        [EXPhotoViewer showImageFrom:fullImage withProgressIndicator:progressLabel];
        
        [fullImage setImageWithURL:reddit.url placeholderImage:[UIImage imageNamed:@"placeholder.jpg"] options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize)
        {
            if (expectedSize > 0) {
                float percentage = (receivedSize/expectedSize)*100;
                DLog(@"percentage: %f",percentage);
                dispatch_async(dispatch_get_main_queue(), ^{
                      progressLabel.text = [NSString stringWithFormat:@"%.2f",percentage];
                });
            }
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            if (!error) {
                _fullImage.image = image;
                [EXPhotoViewer showImageFrom:_fullImage];
            }
        }];
    }
}
@end
