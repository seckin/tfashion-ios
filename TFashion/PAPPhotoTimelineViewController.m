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
#import "CONTagPopover.h"
#import "PINCache.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PAPPhotoTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingPhotoClothesQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingClothClothPiecesQueries;
@end

@implementation PAPPhotoTimelineViewController
@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;
@synthesize outstandingPhotoClothesQueries;
@synthesize outstandingClothClothPiecesQueries;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserLikedUnlikedClothCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPPhotoDetailsViewControllerUserCommentedOnClothNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {

        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        self.outstandingPhotoClothesQueries = [NSMutableDictionary dictionary];
        self.outstandingClothClothPiecesQueries = [NSMutableDictionary dictionary];

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikeCloth:) name:PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikeCloth:) name:PAPUtilityUserLikedUnlikedClothCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnCloth:) name:PAPPhotoDetailsViewControllerUserCommentedOnClothNotification object:nil];
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
//    NSString *string1 = [NSString stringWithFormat:@"%ld", (long)indexPath.section];
//    NSString *string2 = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
//    string1 = [string1 stringByAppendingString:string2];
    NSString *CellIdentifier = @"Cell";
    
    NSUInteger index = [self indexForObjectAtIndexPath:indexPath];

    if (indexPath.row % 2 == 0) {
        return [self detailPhotoCellForRowAtIndexPath:indexPath];
    } else {
        [tableView registerClass:[PAPPhotoCell class] forCellReuseIdentifier:CellIdentifier];
        PAPPhotoCell *cell = (PAPPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.tag = index;
        cell.photoButton.tag = index;
        cell.photo = object;
        
        // remove residual popovers
        for (UIView *subV in [cell.contentView subviews]) {
            if([subV isKindOfClass:[CONTagPopover class]]) {
                [subV removeFromSuperview];
            }
        }

        if (object) {
            cell.imageView.file = [object objectForKey:kPAPPhotoPictureKey];
            cell.clothOverlays = [[NSMutableArray alloc] init];
            
            @synchronized(self) {
                // check if there is already a cloth query running for this photo
                NSNumber *outstandingPhotoClothesQueryStatus = [self.outstandingPhotoClothesQueries objectForKey:@(index)];
                if (!outstandingPhotoClothesQueryStatus) {
                    __block NSArray *cachedclothes;
                    // check if we have already fetched this photo's clothes
                    [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothesForPhoto:object] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
                        cachedclothes = (NSArray *)tmpobj;

                        if(!cachedclothes) {
                            // we have not fetched this photo's clothes yet
                            [self.outstandingPhotoClothesQueries setObject:@"YES" forKey:@(index)];
                            PFQuery *query = [PAPUtility queryForClothesOnPhoto:object cachePolicy:kPFCachePolicyNetworkOnly];
                            [query findObjectsInBackgroundWithBlock:^(NSArray *clothes, NSError *error) {
                                @synchronized (self) {
                                    [self.outstandingPhotoClothesQueries removeObjectForKey:@(index)];

                                    if (error) {
                                        return;
                                    }

                                    if([cachedclothes count] == [clothes count]) {
                                        return;
                                    }

                                    [[PINMemoryCache sharedCache] setObject:clothes forKey:[PAPCache getKeyForClothesForPhoto:object] block:nil];


                                    for (int j = 0; j < [clothes count]; j++) {
                                        PFObject *cloth = [clothes objectAtIndex:j];
                                        [[PAPCache sharedCache] setAttributesForCloth:cloth likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];

                                        @synchronized (self) {
                                            // check if we have already fetched this cloth's cloth_pieces
                                            NSNumber *outstandingClothClothPiecesQueryStatus = [self.outstandingClothClothPiecesQueries objectForKey:cloth];
                                            if (!outstandingClothClothPiecesQueryStatus) {
                                                __block NSArray *cachedclothpieces;
                                                // check if we have already fetched this photo's clothes
                                                [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothPiecesForCloth:cloth] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
                                                    cachedclothpieces = (NSArray *)tmpobj;

                                                    if(!cachedclothpieces) {
                                                        // we have not fetched this cloth's cloth_pieces yet
                                                        [self.outstandingClothClothPiecesQueries setObject:@"YES" forKey:cloth.objectId];
                                                        PFQuery *clothPiecesQuery = [PAPUtility queryForClothPiecesOfCloth:cloth cachePolicy:kPFCachePolicyNetworkOnly];
                                                        [clothPiecesQuery findObjectsInBackgroundWithBlock:^(NSArray *cloth_pieces, NSError *error) {
                                                            @synchronized (self) {
                                                                [self.outstandingClothClothPiecesQueries removeObjectForKey:cloth.objectId];
                                                                if (error) {
                                                                    return;
                                                                }

                                                                if([cachedclothpieces count] == [cloth_pieces count]) {
                                                                    return;
                                                                }

                                                                [[PINMemoryCache sharedCache] setObject:cloth_pieces forKey:[PAPCache getKeyForClothPiecesForCloth:cloth] block:nil];
                                                                [self.tableView reloadData];
                                                            }
                                                        }];
                                                    }
                                                }];
                                            }
                                        }
                                    }
                                }
                            }];
                        }
                    }];


                }
            }


            __block NSArray *clothes;
            [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothesForPhoto:object] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
                clothes = (NSArray *)tmpobj;
                NSLog(@"clothes fetched: %lu", (unsigned long)clothes.count);

//                    if(cell.tagPopovers.count < [clothes count]) {
//                        cell.tagPopovers = [[NSMutableArray alloc] initWithCapacity:[clothes count]];
//                        for(int j = 0; j < [clothes count]; j++) {
//                            [cell.tagPopovers addObject:[NSNull null]];
//                        }
//                    }

                for (int i = 0; i < [clothes count]; i++) {
                    __block PFObject *cloth = [clothes objectAtIndex:i];
                    __block NSArray *cached_cloth_pieces;
                    __block PFObject *block_photo = cell.photo;
                    [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothPiecesForCloth:cloth] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cached_cloth_pieces = (NSArray *) tmpobj;
                            NSLog(@"cached_cloth_pieces fetched: %lu", (unsigned long) cached_cloth_pieces.count);

                            if ([cached_cloth_pieces count] > 0) {
//                                    CONDEMOTag *tag = [CONDEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.0f, 0.0f)],
//                                            @"tagText" : @""}];
//                                    CONTagPopover *tmp_popover = [[CONTagPopover alloc] init];
                                NSLog(@"cloth in block: %@", cloth.objectId);
                                CONTagPopover *tmp_popover = [CONTagPopover alloc];
                                tmp_popover = [tmp_popover initWithPhoto:block_photo cloth:cloth];
                                NSLog(@"tmp_popover.cloth: %@", tmp_popover.cloth.objectId);


//                                [tmp_popover initWithTag:tag];

                                PFObject *cloth_piece = [cached_cloth_pieces objectAtIndex:0];

                                NSMutableArray *boundary_points = [cloth_piece objectForKey:@"boundary_points"];

                                CGFloat x, y, cum_x = 0.0f, cum_y = 0.0f, avg_x, avg_y;
                                for (int k = 0; k < [boundary_points count]; k++) {
                                    cum_x += (CGFloat) [boundary_points[k][0] floatValue];
                                    cum_y += (CGFloat) [boundary_points[k][1] floatValue];
                                }
                                avg_x = cum_x / [boundary_points count];
                                avg_y = cum_y / [boundary_points count];

                                float scale = 320.0 / 560.0;

                                if (![cell.contentView viewWithTag:i] || [cell.contentView viewWithTag:i] == cell.contentView) {
                                    NSLog(@"tmp_popover: %@", tmp_popover);
                                    NSLog(@"adding popover");
                                    tmp_popover.tag = i;

                                    NSLog(@"about to call presentPopoverFromPoint");
                                    [tmp_popover presentPopoverFromPoint:CGPointMake(avg_x * scale, avg_y * scale) inRect:CGRectMake(0.0f, 0.0f, cell.bounds.size.width, cell.bounds.size.width) inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];
                                    NSLog(@"presentPopoverFromPoint done");

                                    UIButton *tagpopoverLayover = [UIButton buttonWithType:UIButtonTypeCustom];
                                    tagpopoverLayover.frame = CGRectMake(0.0f, 0.0f, tmp_popover.bounds.size.width, tmp_popover.bounds.size.width);
                                    tagpopoverLayover.backgroundColor = [UIColor clearColor];
                                    tagpopoverLayover.contentMode = UIViewContentModeScaleAspectFit;
                                    [tagpopoverLayover addTarget:self action:@selector(didTapOnPopoverAction:) forControlEvents:UIControlEventTouchUpInside];
                                    [tmp_popover addSubview:tagpopoverLayover];
//                                        [cell.tagPopovers replaceObjectAtIndex:i withObject:tmp_popover];


//                                        [cell.contentView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
                                    //                                    [cell.tagPopovers performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];


//                                    NSLog(@"cell setNeedsDisplay called inside tagpopoverLayover part2");


                                } else {
                                    NSLog(@"not adding popover");
                                    NSLog(@"coz class type: %@", [[cell.contentView viewWithTag:i] class]);
                                }
                            }
                        });
                    }];

                }
            }];
            NSLog(@"cell setNeedsDisplay called");
            [cell.contentView setNeedsDisplay];
            [CATransaction flush];


//            NSLog(@"cell.imageView.file.url = %@", cell.imageView.file.url);
            NSString *substring = [cell.imageView.file.url substringFromIndex:7];
            NSString *prefix = @"https://s3.amazonaws.com/";
            NSString *httpsfileurl = [prefix stringByAppendingString:substring];
//            NSLog(@"httpsfileurl = %@", httpsfileurl);
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:httpsfileurl] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        }


        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {

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

// *** TODO: remove this function
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo {
//    [photoHeaderView shouldEnableLikeButton:NO];
//
//    BOOL liked = !button.selected;
//    [photoHeaderView setLikeStatus:liked];
//
//    NSString *originalButtonTitle = button.titleLabel.text;
//
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//
//    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
//    if (liked) {
//        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
//        [[PAPCache sharedCache] incrementLikerCountForPhoto:photo];
//    } else {
//        if ([likeCount intValue] > 0) {
//            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
//        }
//        [[PAPCache sharedCache] decrementLikerCountForPhoto:photo];
//    }
//
//    [[PAPCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];
//
//    [button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
//
//    if (liked) {
//        [PAPUtility likePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
//            PAPPhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
//            [actualHeaderView shouldEnableLikeButton:YES];
//            [actualHeaderView setLikeStatus:succeeded];
//
//            if (!succeeded) {
//                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
//            }
//        }];
//    } else {
//        [PAPUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
//            PAPPhotoHeaderView *actualHeaderView = (PAPPhotoHeaderView *)[self tableView:self.tableView viewForHeaderInSection:button.tag];
//            [actualHeaderView shouldEnableLikeButton:YES];
//            [actualHeaderView setLikeStatus:!succeeded];
//
//            if (!succeeded) {
//                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];
//            }
//        }];
//    }
}

- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapCommentOnPhotoButton:(UIButton *)button  photo:(PFObject *)photo {
//    PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo];
//    [self.navigationController pushViewController:photoDetailsVC animated:YES];
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

    headerView.likeButton.alpha = 0.0f;
    headerView.commentButton.alpha = 0.0f;

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

- (void)userDidLikeOrUnlikeCloth:(NSNotification *)note {
    NSLog(@"inside userDidLikeOrUnlikeCloth");
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];
    [self.tableView reloadData];
}

- (void)userDidCommentOnCloth:(NSNotification *)note {
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];
    [self.tableView reloadData];
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
    NSLog(@"didTapOnPopoverAction called");
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    PFObject *photo = self.objects[view.tag];
    UIView *popover = sender.superview;
    __block int cloth_index = popover.tag;
    NSLog(@"cloth_index  : %d",cloth_index );
    __block NSArray *cachedclothes;
    [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothesForPhoto:photo] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
        cachedclothes = (NSArray *) tmpobj;
        PFObject *cloth = cachedclothes[cloth_index];
        NSLog(@"cloth fetched - cloth id = %@", cloth.objectId);
        dispatch_async(dispatch_get_main_queue(), ^{
            PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo cloth:cloth];
    //        [photoDetailsVC setPhoto:photo setCloth:cloth];
            NSLog(@"navigationcontroller being called:");
            NSLog(@"nav controller = %@", self.navigationController);

            [self.navigationController pushViewController:photoDetailsVC animated:YES];
        });
    }];
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
