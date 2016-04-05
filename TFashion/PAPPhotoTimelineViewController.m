
#import "PAPPhotoTimelineViewController.h"
#import "PAPPhotoCell.h"
#import "PAPAccountViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "PAPUtility.h"
#import "PAPLoadMoreCell.h"
#import "AppDelegate.h"
#import "CONTagPopover.h"
#import "PINCache.h"
#import "PAPFindFriendsViewController.h"
#import "PAPPhotoEmptySpaceView.h"
#import "CONPhotoCaptionView.h"
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
        self.loadingViewEnabled = YES;

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
    return self.objects.count * 4 + (self.paginationEnabled ? 1 : 0);
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
    if (self.paginationEnabled && (self.objects.count * 4) == indexPath.row) {
        // Load More Section
        return 44.0f;
    } else if (indexPath.row % 4 == 0) {
        // profile header part
        return 44.0f;
    } else if (indexPath.row % 4 == 3) {
        // empty space
        return 10.0f;
    } else if (indexPath.row % 4 == 2) {
        // caption space
        return 43.0f;
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
    NSString *CellIdentifier = @"Cell";
    
    NSUInteger index = [self indexForObjectAtIndexPath:indexPath];

    if (indexPath.row % 4 == 0) {
        return [self detailPhotoCellForRowAtIndexPath:indexPath];
    } else if (indexPath.row % 4 == 3) {
        return [self emptyspacePhotoCellForRowAtIndexPath:indexPath];
    } else if (indexPath.row % 4 == 2) {
        if([object objectForKey:@"caption"] && [[object objectForKey:@"caption"] length] > 0) {
            return [self captionPhotoCellForRowAtIndexPath:indexPath];
        } else {
            return [self emptyspacePhotoCellForRowAtIndexPath:indexPath];
        }
    } else {
        [tableView registerClass:[PAPPhotoCell class] forCellReuseIdentifier:CellIdentifier];
        PAPPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.tag = index;
        cell.photoButton.tag = index;
        cell.photo = object;
        PAPBaseTextCell *captioncell = [[PAPBaseTextCell alloc] init];
        cell.captioncell = captioncell;
        
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

                for (int i = 0; i < [clothes count]; i++) {
                    __block PFObject *cloth = [clothes objectAtIndex:i];
                    __block NSArray *cached_cloth_pieces;
                    __block PFObject *block_photo = cell.photo;
                    [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothPiecesForCloth:cloth] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cached_cloth_pieces = (NSArray *) tmpobj;

                            if ([cached_cloth_pieces count] > 0) {
                                CONTagPopover *tmp_popover = [CONTagPopover alloc];
                                tmp_popover = [tmp_popover initWithPhoto:block_photo cloth:cloth];

                                PFObject *cloth_piece = [cached_cloth_pieces objectAtIndex:0];

                                NSMutableArray *boundary_points = [cloth_piece objectForKey:@"boundary_points"];

                                CGFloat cum_x = 0.0f, cum_y = 0.0f, avg_x, avg_y;
                                for (int k = 0; k < [boundary_points count]; k++) {
                                    cum_x += (CGFloat) [boundary_points[k][0] floatValue];
                                    cum_y += (CGFloat) [boundary_points[k][1] floatValue];
                                }
                                avg_x = cum_x / [boundary_points count];
                                avg_y = cum_y / [boundary_points count];

                                float scale = 320.0 / 560.0;

                                if (![cell.contentView viewWithTag:i] || [cell.contentView viewWithTag:i] == cell.contentView) {
                                    tmp_popover.tag = i;

                                    [tmp_popover presentPopoverFromPoint:CGPointMake(avg_x * scale, avg_y * scale) inRect:CGRectMake(0.0f, 0.0f, cell.bounds.size.width, cell.bounds.size.width) inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];

                                    UIButton *tagpopoverLayover = [UIButton buttonWithType:UIButtonTypeCustom];
                                    tagpopoverLayover.frame = CGRectMake(0.0f, 0.0f, tmp_popover.bounds.size.width, tmp_popover.bounds.size.width);
                                    tagpopoverLayover.backgroundColor = [UIColor clearColor];
                                    tagpopoverLayover.contentMode = UIViewContentModeScaleAspectFit;
                                    [tagpopoverLayover addTarget:self action:@selector(didTapOnPopoverAction:) forControlEvents:UIControlEventTouchUpInside];
                                    [tmp_popover addSubview:tagpopoverLayover];
                                } else {
                                    NSLog(@"not adding popover");
                                    NSLog(@"coz class type: %@", [[cell.contentView viewWithTag:i] class]);
                                }
                            }
                        });
                    }];

                }
            }];

            [cell.captioncell setContentObject:[object objectForKey:kPAPPhotoCaptionKey]];
            [cell.captioncell setContentText:[object objectForKey:kPAPPhotoCaptionKey]];

            [cell.contentView setNeedsDisplay];
            [CATransaction flush];

            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:cell.imageView.file.url] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
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

#pragma mark - ()

- (UITableViewCell *)detailPhotoCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DetailPhotoCell";

    if (self.paginationEnabled && indexPath.row == self.objects.count * 4) {
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

    return headerView;
}


- (UITableViewCell *)captionPhotoCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CaptionPhotoCell";

    if (self.paginationEnabled && indexPath.row == self.objects.count * 4) {
        // Load More section
        return nil;
    }

    NSUInteger index = [self indexForObjectAtIndexPath:indexPath];

    CONPhotoCaptionView *captionView;
//    CONPhotoCaptionView *captionView = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PFObject *object = [self objectAtIndexPath:indexPath];
    if (!captionView) {
        captionView = [[CONPhotoCaptionView alloc] initWithPhoto:object];
        captionView.delegate = self;
        captionView.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    captionView.photo = object;
    captionView.tag = index;

    return captionView;
}

- (UITableViewCell *)emptyspacePhotoCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"emptyspacePhotoCell";

    if (self.paginationEnabled && indexPath.row == self.objects.count * 4) {
        // Load More section
        return nil;
    }

    NSUInteger index = [self indexForObjectAtIndexPath:indexPath];

    PAPPhotoEmptySpaceView *emptyspaceView = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!emptyspaceView) {
        emptyspaceView = [[PAPPhotoEmptySpaceView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 10.0f)];
        emptyspaceView.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    PFObject *object = [self objectAtIndexPath:indexPath];
//    emptyspaceView.photo = object;
    emptyspaceView.tag = index;
    return emptyspaceView;
}

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:i*4+1 inSection:0];
        }
    }

    return nil;
}

- (void)userDidLikeOrUnlikeCloth:(NSNotification *)note {
    [self.tableView reloadData];
}

- (void)userDidCommentOnCloth:(NSNotification *)note {
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
    self.shouldReloadOnAppear = YES;
}

- (void)didTapOnPopoverAction:(UIButton *)sender {
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    PFObject *photo = self.objects[view.tag];
    UIView *popover = sender.superview;
    __block int cloth_index = popover.tag;
    __block NSArray *cachedclothes;
    [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothesForPhoto:photo] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
        cachedclothes = (NSArray *) tmpobj;
        PFObject *cloth = cachedclothes[cloth_index];
        dispatch_async(dispatch_get_main_queue(), ^{
            PAPPhotoDetailsViewController *photoDetailsVC = [[PAPPhotoDetailsViewController alloc] initWithPhoto:photo cloth:cloth];

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
    return [NSIndexPath indexPathForItem:(index * 4 + (header ? 0 : 1)) inSection:0];
}

- (NSUInteger)indexForObjectAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row / 4;
}

- (void)inviteFriendsButtonAction:(id)sender {
    PAPFindFriendsViewController *detailViewController = [[PAPFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


@end
