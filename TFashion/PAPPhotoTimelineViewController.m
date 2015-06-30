//
//  PAPPhotoTimelineViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/2/12.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import "PAPPhotoTimelineViewController.h"
#import "PAPPhotoCell.h"
#import "PAPAccountViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "PAPUtility.h"
#import "PAPLoadMoreCell.h"
#import "AppDelegate.h"
#import "CONImageOverlay.h"
#import "CONDemoTag.h"
#import "CONTagPopover.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PAPPhotoTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@end

@implementation PAPPhotoTimelineViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {

        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];

        // The className to query on
        self.parseClassName = kPAPPhotoClassKey;

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;

        // The number of objects to show per page
        // self.objectsPerPage = 10;

        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];

        // The Loading text clashes with the dark Anypic design
        self.loadingViewEnabled = NO;

        self.shouldReloadOnAppear = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:PAPUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count * 2 + (self.paginationEnabled ? 1 : 0);
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.paginationEnabled && (self.objects.count * 2) == indexPath.row) {
        // Load More Section
        return 44.0f;
    } else if (indexPath.row % 2 == 0) {
        return 44.0f;
    }

    return 320.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (![self objectAtIndexPath:indexPath]) {
        // Load More Cell
        [self loadNextPage];
    }
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }

    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 1000;

    PFQuery *autoFollowUsersQuery = [PFUser query];
    [autoFollowUsersQuery whereKey:kPAPUserAutoFollowKey equalTo:@YES];

    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromFollowedUsersQuery whereKey:kPAPPhotoUserKey matchesKey:kPAPActivityToUserKey inQuery:followingActivitiesQuery];
    [photosFromFollowedUsersQuery whereKeyExists:kPAPPhotoPictureKey];

    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromCurrentUserQuery whereKey:kPAPPhotoUserKey equalTo:[PFUser currentUser]];
    [photosFromCurrentUserQuery whereKeyExists:kPAPPhotoPictureKey];

    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, photosFromCurrentUserQuery, nil]];
    [query setLimit:30];
    [query includeKey:kPAPPhotoUserKey];
    [query orderByDescending:@"createdAt"];

    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }

    /*
     This query will result in an error if the schema hasn't been set beforehand. While Parse usually handles this automatically, this is not the case for a compound query such as this one. The error thrown is:
     
     Error: bad special key: __type
     
     To set up your schema, you may post a photo with a caption. This will automatically set up the Photo and Activity classes needed by this query.
     
     You may also use the Data Browser at Parse.com to set up your classes in the following manner.
     
     Create a User class: "User" (if it does not exist)
     
     Create a Custom class: "Activity"
     - Add a column of type pointer to "User", named "fromUser"
     - Add a column of type pointer to "User", named "toUser"
     - Add a string column "type"
     
     Create a Custom class: "Photo"
     - Add a column of type pointer to "User", named "user"
     
     You'll notice that these correspond to each of the fields used by the preceding query.
     */

    return query;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [self indexForObjectAtIndexPath:indexPath];
    if (index < self.objects.count) {
        return self.objects[index];
    }

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";

    NSUInteger index = [self indexForObjectAtIndexPath:indexPath];

    if (indexPath.row % 2 == 0) {
        return [self detailPhotoCellForRowAtIndexPath:indexPath];
    } else {
        PAPPhotoCell *cell = (PAPPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) {
            cell = [[PAPPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        cell.photoButton.tag = index;

        if (object) {
            cell.imageView.file = [object objectForKey:kPAPPhotoPictureKey];
            cell.clothOverlays = [[NSMutableArray alloc] init];
            cell.clothesDataArr = [[NSMutableArray alloc] init];

                PFQuery *query = [PAPUtility queryForClothesOnPhoto:object cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *cloths, NSError *error) {
                        if (error) {
                            return;
                        }
//                        NSLog(@"photo id : %@, objects(clothes) count: %lu", object.objectId, (unsigned long)[cloths count]);

                        NSMutableArray *clothes_data_arr = [NSMutableArray array];
                        // clothes_data_arr eventually has [0: {"cloth": CLOTH_OBJ, "cloth_pieces": CLOTH_PIECES_ARR}, 1: {cloth, cloth_pieces}, ...] type of data in it.

                        for(int j = 0; j < [cloths count]; j++) {
                            PFObject *cloth = [cloths objectAtIndex:j];
                            PFQuery *clothPiecesQuery = [PAPUtility queryForClothPiecesOfCloth:cloth cachePolicy:kPFCachePolicyNetworkOnly];
                            [clothPiecesQuery findObjectsInBackgroundWithBlock:^(NSArray *cloth_pieces, NSError *error) {
                                    if (error) {
                                        return;
                                    }
                                    //NSMutableArray *cloth_pieces = [NSMutableArray array];
                                    NSLog(@"photo id : %@, cloth id : %@,  clothPieces count: %lu", object.objectId, cloth.objectId, (unsigned long) [cloth_pieces count]);

                                    // create one popover for each cloth, and populate the like/comment counts
                                    for (int i = 0; i < [cloth_pieces count]; i++) {
                                        PFObject *cloth_piece = [cloth_pieces objectAtIndex:i];
//                                        NSLog(@"photo id : %@, cloth id : %@,  clothPiece id: %@", object.objectId, cloth.objectId, cloth_piece.objectId);
                                    }
                                    NSDictionary *cloth_data = [NSDictionary dictionaryWithObjects:@[cloth, cloth_pieces] forKeys:@[@"cloth", @"cloth_pieces"]];
                                    [clothes_data_arr addObject:cloth_data];


                                    NSLog(@"adding to clothesDataArr");
                                    [cell.clothesDataArr addObject:cloth_data];

//                                    NSArray *cloth_pieces = [cloth_data objectForKey:@"cloth_pieces"];

                                    PFObject *cloth_piece = [cloth_pieces objectAtIndex:0];
                                    NSMutableArray *boundary_points = [cloth_piece objectForKey:@"boundary_points"];

                                    CGFloat x,y, cum_x = 0.0f, cum_y = 0.0f, avg_x, avg_y;
                                    for(int j = 0; j < [boundary_points count]; j++) {
                                        cum_x += (CGFloat)[boundary_points[j][0] floatValue];
                                        cum_y += (CGFloat)[boundary_points[j][1] floatValue];
                                    }
                                    avg_x = cum_x / [boundary_points count];
                                    avg_y = cum_y / [boundary_points count];

                                    CONDEMOTag *tag = [CONDEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.0f, 0.0f)],
                                            @"tagText" : @""}];

                                    [cell setTag:tag];

                                    cell.tagpopover = [[CONTagPopover alloc] init];//[CONTagPopover initWithTag:self.tag];
                                    [cell.tagpopover initWithTag:cell.tag];

                                    float scale = 320.0 / 560.0;
                                    [cell.tagpopover presentPopoverFromPoint:CGPointMake(avg_x * scale, avg_y * scale) inRect:CGRectMake( 0.0f, 0.0f, cell.bounds.size.width, cell.bounds.size.width) inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];

                                    UIButton *tagpopoverLayover = [UIButton buttonWithType:UIButtonTypeCustom];
                                    tagpopoverLayover.frame = CGRectMake( 0.0f, 0.0f, cell.tagpopover.bounds.size.width, cell.tagpopover.bounds.size.width);
                                    tagpopoverLayover.backgroundColor = [UIColor clearColor];
                                    tagpopoverLayover.contentMode = UIViewContentModeScaleAspectFit;
                                    [tagpopoverLayover addTarget:self action:@selector(didTapOnPopoverAction:) forControlEvents:UIControlEventTouchUpInside];
                                    [cell.tagpopover addSubview:tagpopoverLayover];
                            }];
                        }
                }];

            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:cell.imageView.file.url] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        }

        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";

    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}


#pragma mark - PAPPhotoTimelineViewController

- (PAPPhotoHeaderView *)dequeueReusableSectionHeaderView {
    for (PAPPhotoHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }

    return nil;
}


#pragma mark - PAPPhotoHeaderViewDelegate

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithUser:user];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo {
    [photoHeaderView shouldEnableLikeButton:NO];

    BOOL liked = !button.selected;
    [photoHeaderView setLikeStatus:liked];

    NSString *originalButtonTitle = button.titleLabel.text;

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];

    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[PAPCache sharedCache] incrementLikerCountForPhoto:photo];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[PAPCache sharedCache] decrementLikerCountForPhoto:photo];
    }

    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];

    [button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];

    if (liked) {
        [PAPUtility likePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            PAPPhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableLikeButton:YES];
            [actualHeaderView setLikeStatus:succeeded];

            if (!succeeded) {
                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    } else {
        [PAPUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
            PAPPhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableLikeButton:YES];
            [actualHeaderView setLikeStatus:!succeeded];

            if (!succeeded) {
                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
            }
        }];
    }
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapCommentOnPhotoButton:(UIButton *)button  photo:(PFObject *)photo {
    PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:photoDetailsVC animated:YES];
}


#pragma mark - ()

- (UITableViewCell *)detailPhotoCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DetailPhotoCell";

    if (self.paginationEnabled && indexPath.row == self.objects.count * 2) {
        // Load More section
        return nil;
    }

    NSUInteger index = [self indexForObjectAtIndexPath:indexPath];

    PAPPhotoHeaderView *headerView = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!headerView) {
        headerView = [[PAPPhotoHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 44.0f) buttons:PAPPhotoHeaderButtonsDefault];
        headerView.delegate = self;
        headerView.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    PFObject *object = [self objectAtIndexPath:indexPath];
    headerView.photo = object;
    headerView.tag = index;
    [headerView.likeButton setTag:index];

    NSDictionary *attributesForPhoto = [[PAPCache sharedCache] attributesForPhoto:object];

    if (attributesForPhoto) {
        [headerView setLikeStatus:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:object]];
        [headerView.likeButton setTitle:[[[PAPCache sharedCache] likeCountForPhoto:object] description] forState:UIControlStateNormal];
        [headerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForPhoto:object] description] forState:UIControlStateNormal];

        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
            [UIView animateWithDuration:0.200f animations:^{
                headerView.likeButton.alpha = 1.0f;
                headerView.commentButton.alpha = 1.0f;
            }];
        }
    } else {
        headerView.likeButton.alpha = 0.0f;
        headerView.commentButton.alpha = 0.0f;

        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingSectionHeaderQueryStatus = [self.outstandingSectionHeaderQueries objectForKey:@(index)];
            if (!outstandingSectionHeaderQueryStatus) {
                PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:object cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingSectionHeaderQueries removeObjectForKey:@(index)];

                        if (error) {
                            return;
                        }

                        NSMutableArray *likers = [NSMutableArray array];
                        NSMutableArray *commenters = [NSMutableArray array];

                        BOOL isLikedByCurrentUser = NO;

                        for (PFObject *activity in objects) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                                [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                            }

                            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                    isLikedByCurrentUser = YES;
                                }
                            }
                        }

                        [[PAPCache sharedCache] setAttributesForPhoto:object likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];

                        if (headerView.tag != index) {
                            return;
                        }

                        [headerView setLikeStatus:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:object]];
                        [headerView.likeButton setTitle:[[[PAPCache sharedCache] likeCountForPhoto:object] description] forState:UIControlStateNormal];
                        [headerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForPhoto:object] description] forState:UIControlStateNormal];

                        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
                            [UIView animateWithDuration:0.200f animations:^{
                                headerView.likeButton.alpha = 1.0f;
                                headerView.commentButton.alpha = 1.0f;
                            }];
                        }
                    }
                }];
            }
        }
    }

    return headerView;
}

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:i*2+1 inSection:0];
        }
    }

    return nil;
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    NSLog(@"User following changed.");
    self.shouldReloadOnAppear = YES;
}

- (void)didTapOnPopoverAction:(UIButton *)sender {
    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    if (photo) {
        PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

/*
 For each object in self.objects, we display two cells. If pagination is enabled, there will be an extra cell at the end.
 NSIndexPath     index self.objects
 0 0 HEADER      0
 0 1 PHOTO       0
 0 2 HEADER      1
 0 3 PHOTO       1
 0 4 LOAD MORE
 */

- (NSIndexPath *)indexPathForObjectAtIndex:(NSUInteger)index header:(BOOL)header {
    return [NSIndexPath indexPathForItem:(index * 2 + (header ? 0 : 1)) inSection:0];
}

- (NSUInteger)indexForObjectAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row / 2;
}


@end
