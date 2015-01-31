//
//  CONFollowPopularFeedsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 1/28/15.
//
//

#import "CONFollowPopularFeedsViewController.h"
#import "CONFollowFeedTableViewCell.h"
#import "CONFeedCollectionViewCell.h"
#import "UIColor+InitAdditions.h"
#import <iOS-blur/JCRBlurView.h>
#import <YLProgressBar/YLProgressBar.h>

@interface CONFollowPopularFeedsViewController () <CONFollowFeedTableViewCellDelegate>

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NSMutableArray *selectedFeeds;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) YLProgressBar *progressBarFlatRainbow;

@end

@implementation CONFollowPopularFeedsViewController

- (void)loadView
{
    [super loadView];
    
    NSArray *colorHexArray = @[ @"#ED4A8A", @"#77D8C3", @"#F7CDB5", @"#F02A5C", @"#92ADD4", @"#89DECA", @"#E68F8E" ];
    
    NSMutableArray *colorsMutable = [[NSMutableArray alloc] init];
    for (NSString *colorHex in colorHexArray) {
        [colorsMutable addObject:[UIColor colorWithHex:colorHex alpha:1.0f]];
    }
    self.colors = [NSArray arrayWithArray:colorsMutable];
    
    self.selectedFeeds = [[NSMutableArray alloc] init];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    
    self.tableView.backgroundColor = backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Set header view
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), CGRectGetWidth(self.tableView.bounds)/3)];
    tableHeaderView.backgroundColor = backgroundColor;
    
    UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(tableHeaderView.bounds), CGRectGetHeight(tableHeaderView.bounds)-40)];
    headerTitleLabel.text = @"Follow Interesting\nFeeds";
    headerTitleLabel.textColor = [UIColor whiteColor];
    headerTitleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    headerTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerTitleLabel.numberOfLines = 0;
    
    [tableHeaderView addSubview:headerTitleLabel];
    
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)continueButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ()

- (void)selectCell:(CONFollowFeedTableViewCell *)cell
{
    BOOL IsSelected = cell.followButton.selected;
    [cell.followButton setSelected:!IsSelected];
    if (!IsSelected) {
        [self.selectedFeeds addObject:[self.tableView indexPathForCell:cell]];
    } else {
        [self.selectedFeeds removeObject:[self.tableView indexPathForCell:cell]];
    }
    
    [self editFooterViewAnimated:YES];
}

- (void)customizeFlatRainbowProgressBar
{
    NSArray *tintColors = @[[UIColor colorWithRed:33/255.0f green:180/255.0f blue:162/255.0f alpha:1.0f],
                            [UIColor colorWithRed:3/255.0f green:137/255.0f blue:166/255.0f alpha:1.0f],
                            [UIColor colorWithRed:91/255.0f green:63/255.0f blue:150/255.0f alpha:1.0f],
                            [UIColor colorWithRed:87/255.0f green:26/255.0f blue:70/255.0f alpha:1.0f],
                            [UIColor colorWithRed:126/255.0f green:26/255.0f blue:36/255.0f alpha:1.0f],
                            [UIColor colorWithRed:149/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f],
                            [UIColor colorWithRed:228/255.0f green:69/255.0f blue:39/255.0f alpha:1.0f],
                            [UIColor colorWithRed:245/255.0f green:166/255.0f blue:35/255.0f alpha:1.0f],
                            [UIColor colorWithRed:165/255.0f green:202/255.0f blue:60/255.0f alpha:1.0f],
                            [UIColor colorWithRed:202/255.0f green:217/255.0f blue:54/255.0f alpha:1.0f],
                            [UIColor colorWithRed:111/255.0f green:188/255.0f blue:84/255.0f alpha:1.0f]];
    
    _progressBarFlatRainbow.type               = YLProgressBarTypeFlat;
    _progressBarFlatRainbow.progressTintColors = tintColors;
    _progressBarFlatRainbow.hideStripes        = YES;
    _progressBarFlatRainbow.hideTrack          = YES;
    _progressBarFlatRainbow.behavior           = YLProgressBarBehaviorDefault;
}

- (void)editFooterViewAnimated:(BOOL)animated
{
    CGFloat selectedFeedCount = self.selectedFeeds.count;
    
    if (MAX(0, 4-selectedFeedCount) == 0) {
        self.footerLabel.hidden = YES;
        self.continueButton.hidden = NO;
    } else {
        self.continueButton.hidden = YES;
        self.footerLabel.hidden = NO;
        self.footerLabel.text = [NSString stringWithFormat:@"Tap at least %d more to continue", (int)MAX(0, 4-selectedFeedCount)];
    }
    
    CGFloat progress;
    if (selectedFeedCount >= 4) {
        progress = 1;
    } else {
        progress = selectedFeedCount/4;
    }
    [_progressBarFlatRainbow setProgress:progress animated:animated];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    CONFollowFeedTableViewCell *cell = (CONFollowFeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[CONFollowFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.followButton setSelected:[self.selectedFeeds containsObject:indexPath]];
    
    cell.delegate = self;
    cell.backgroundColor = [self.colors objectAtIndex:indexPath.row%self.colors.count];
    
    cell.titleLabel.text = @"Rave Inspiration";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(CONFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    JCRBlurView *footerView = [[JCRBlurView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(tableView.bounds) - 44.0f, CGRectGetWidth(tableView.bounds), 44.0f)];
    footerView.blurTintColor = [UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    
    // Initialize footer label
    self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, CGRectGetWidth(footerView.bounds), 20)];
    self.footerLabel.font = [UIFont systemFontOfSize:15.0f];
    self.footerLabel.textColor = [UIColor grayColor];
    self.footerLabel.textAlignment = NSTextAlignmentCenter;
    [footerView addSubview:self.footerLabel];
    
    // Initialize continue button
    self.continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.continueButton setFrame:CGRectMake(60, 12, CGRectGetWidth(footerView.bounds) - 120, 25)];
    self.continueButton.backgroundColor = [UIColor colorWithHex:@"#16a9c7" alpha:1.0f];
    self.continueButton.clipsToBounds = YES;
    self.continueButton.layer.cornerRadius = 5;
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.continueButton];
    
    // Initialize progress bar
    self.progressBarFlatRainbow = [[YLProgressBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(footerView.bounds), 3)];
    [self customizeFlatRainbowProgressBar];
    [footerView addSubview:self.progressBarFlatRainbow];
    
    // Edit footer view to set initial values
    [self editFooterViewAnimated:NO];
    
    return footerView;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CONFollowFeedTableViewCell heightForCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CONFollowFeedTableViewCell *cell = (CONFollowFeedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self selectCell:cell];
}

#pragma mark - <CONFollowFeedTableViewCellDelegate>

- (void)followFeedTableViewCellDidClickedFollowButton:(CONFollowFeedTableViewCell *)followFeedTableViewCell
{
    [self selectCell:followFeedTableViewCell];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CONFeedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
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

@end
