//
//  CONFeedViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/23/14.
//
//

#import "CONFeedTimelineViewController.h"
#import "CONFeedTableViewCell.h"
#import "CONFeedCollectionViewCell.h"
#import "PAPSettingsButtonItem.h"
#import "CONSettingsViewController.h"
#import "CONInstagramMedium.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface CONFeedTimelineViewController ()
@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NSArray *feedMedia;

@end

@implementation CONFeedTimelineViewController

- (void)loadView
{
    [super loadView];
    
    const NSInteger numberOfTableViewRows = 20;
    const NSInteger numberOfCollectionViewCells = 15;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            
            [colorArray addObject:color];
        }
        
        [mutableArray addObject:colorArray];
    }
    
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    // Add Settings button
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"+ Add More" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [addButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [addButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [addButton setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30.0f)];
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = addButton;
    
    [self getFeedMedia];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)addButtonAction:(id)sender
{
    
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    CONFeedTableViewCell *cell = (CONFeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CONFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.titleLabel.text = @"Instagram #color";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(CONFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CONFeedTableViewCell heightForCell];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionViewArray = self.colorArray[collectionView.tag];
    return collectionViewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CONFeedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSArray *collectionViewArray = self.colorArray[collectionView.tag];
    cell.imageView.backgroundColor = collectionViewArray[indexPath.item];
    
    if (collectionView.tag == 0) {
        CONInstagramMedium *instagramMedium = [self.feedMedia objectAtIndex:indexPath.item];
        [cell.imageView sd_setImageWithURL:instagramMedium.standardResolutionImageURL];
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

#pragma mark - ()

- (void)settingsButtonAction:(id)sender {
    CONSettingsViewController *settingsVC = [[CONSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)getFeedMedia
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://23.92.27.159:8091/test1" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSError *error = nil;
        self.feedMedia = [MTLJSONAdapter modelsOfClass:CONInstagramMedium.class fromJSONArray:[responseObject valueForKey:@"data"] error:&error];
        NSLog(@"mantle error: %@", error);
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
