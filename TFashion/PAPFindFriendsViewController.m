//
//  PAPFindFriendsViewController.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPFindFriendsViewController.h"
#import "PAPLoadMoreCell.h"
#import "PAPAccountViewController.h"
#import "CONInviteFriendsViewController.h"

typedef enum {
    PAPFindFriendsFollowingNone = 0,    // User isn't following anybody in Friends list
    PAPFindFriendsFollowingAll,         // User is following all Friends
    PAPFindFriendsFollowingSome         // User is following some of their Friends
} PAPFindFriendsFollowStatus;

@interface PAPFindFriendsViewController ()
{
    NSArray *searchResults;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) PAPFindFriendsFollowStatus followStatus;
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;

@end

static const NSUInteger kSearchResultLimit = 20;

@implementation PAPFindFriendsViewController
@synthesize headerView;
@synthesize followStatus;
@synthesize selectedEmailAddress;
@synthesize outstandingFollowQueries;
@synthesize outstandingCountQueries;
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        self.selectedEmailAddress = @"";

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // The number of objects to show per page
        self.objectsPerPage = 15;
        
        // Used to determine Follow/Unfollow All button status
        self.followStatus = PAPFindFriendsFollowingSome;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = @"Find Friends";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    [self.headerView setBackgroundColor:[UIColor whiteColor]];
//    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [clearButton setBackgroundColor:[UIColor clearColor]];
//    [clearButton addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [clearButton setFrame:self.headerView.frame];
//    [self.headerView addSubview:clearButton];
//    NSString *inviteString = @"Choose contacts to invite";
//    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
//    textStyle.alignment = NSTextAlignmentCenter;
//    CGRect boundingRect = [inviteString boundingRectWithSize:CGSizeMake(310.0f, CGFLOAT_MAX)
//                                                     options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
//                                                  attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:13.0f], NSParagraphStyleAttributeName: textStyle }
//                                                     context:nil];
//    CGSize inviteStringSize = boundingRect.size;
//
//    UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.headerView.frame.size.height-inviteStringSize.height)/2, inviteStringSize.width, inviteStringSize.height)];
//    [inviteLabel setText:inviteString];
//    [inviteLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:13]];
//    [inviteLabel setTextColor:[UIColor blackColor]];
//    [inviteLabel setBackgroundColor:[UIColor clearColor]];
//    [self.headerView addSubview:inviteLabel];
    
//    FAKIonIcons *chevronRightIcon = [FAKIonIcons chevronRightIconWithSize:17];
//    [chevronRightIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
//    UILabel *chevronLabel = [[UILabel alloc] init];
//    chevronLabel.attributedText = [chevronRightIcon attributedString];
//    [chevronLabel sizeToFit];
//    chevronLabel.center = CGPointMake(CGRectGetMaxX(inviteLabel.frame)+10, inviteLabel.center.y+1);
//    [self.headerView addSubview:chevronLabel];
    
    [self.tableView setTableHeaderView:self.headerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.separatorColor = [UIColor colorWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:0.5f];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        return [PAPFindFriendsCell heightForCell];
    } else {
//        return 44.0f;
        return 0.0f;
    }
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return NO;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    NSMutableArray *subQueryArray = [[NSMutableArray alloc] init];
    
    // Use cached facebook friend ids
    NSArray *facebookFriends = [[PAPCache sharedCache] facebookFriends];
    
    if (facebookFriends) {
        // Query for all friends you have on facebook and who are using the app
        PFQuery *friendsQuery = [PFUser query];
        [friendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookFriends];
        [subQueryArray addObject:friendsQuery];
    }

    PFQuery *mostUploadersQuery = [PFUser query]; //[PFQuery queryWithClassName:@"_User"];
    [mostUploadersQuery whereKey:kPAPUserNumPhotosKey greaterThan:[NSNumber numberWithInt:0]];
    [mostUploadersQuery whereKey:kPAPUserObjectIdKey notEqualTo:[[PFUser currentUser] objectId]];
    //[mostUploadersQuery setLimit:2];
    //[mostUploadersQuery orderByDescending:@"displayName"];
    [mostUploadersQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [subQueryArray addObject:mostUploadersQuery];
        
    PFQuery *query = [PFQuery orQueryWithSubqueries:subQueryArray];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:kPAPUserDisplayNameKey];
    
    return query;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if (searchText.length == 0) {
        searchResults = nil;
        return;
    }
    NSMutableArray *subQueryArray = [[NSMutableArray alloc] init];
    
    PFQuery *query1 = [PFUser query];
    // Modifier "i" is for making search case-insensitive
    [query1 whereKey:@"username" matchesRegex:searchText modifiers:@"i"];
    [query1 whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [subQueryArray addObject:query1];
    
    PFQuery *query2 = [PFUser query];
    // Modifier "i" is for making search case-insensitive
    [query2 whereKey:@"displayName" matchesRegex:searchText modifiers:@"i"];
    [query2 whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    [subQueryArray addObject:query2];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:subQueryArray];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    [query orderByAscending:kPAPUserDisplayNameKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            searchResults = objects;
            [searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [isFollowingQuery whereKey:kPAPActivityToUserKey containedIn:self.objects];
    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number == self.objects.count) {
                self.followStatus = PAPFindFriendsFollowingAll;
                for (PFUser *user in self.objects) {
                    [[PAPCache sharedCache] setFollowStatus:YES user:user];
                }
            } else if (number == 0) {
                self.followStatus = PAPFindFriendsFollowingNone;
                for (PFUser *user in self.objects) {
                    [[PAPCache sharedCache] setFollowStatus:NO user:user];
                }
            } else {
                self.followStatus = PAPFindFriendsFollowingSome;
            }
        }
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        PFTableViewCell *cell;
        if (searchResults.count > 0) {
            if ([searchResults objectAtIndex:indexPath.row]) {
                cell = [self tableView:tableView cellForRowAtIndexPath:indexPath object:[searchResults objectAtIndex:indexPath.row]];
            }
        }
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    [cell setUser:(PFUser*)object];
    
    if (tableView == searchDisplayController.searchResultsTableView) {
        [cell.followButton removeFromSuperview];
        cell.photoLabel.text = cell.user.username;
        return cell;
    }

    [cell.photoLabel setText:@"0 photos"];
    
    NSDictionary *attributes = [[PAPCache sharedCache] attributesForUser:(PFUser *)object];
    
    if (attributes) {
        // set them now
        NSNumber *number = [[PAPCache sharedCache] photoCountForUser:(PFUser *)object];
        [cell.photoLabel setText:[NSString stringWithFormat:@"%@ photo%@", number, [number intValue] == 1 ? @"": @"s"]];
    } else {
        @synchronized(self) {
            NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
            if (!outstandingCountQueryStatus) {
                [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                PFQuery *photoNumQuery = [PFQuery queryWithClassName:kPAPPhotoClassKey];
                [photoNumQuery whereKey:kPAPPhotoUserKey equalTo:object];
                [photoNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [photoNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    @synchronized(self) {
                        [[PAPCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:(PFUser *)object];
                        [self.outstandingCountQueries removeObjectForKey:indexPath];
                    }
                    PAPFindFriendsCell *actualCell = (PAPFindFriendsCell*)[tableView cellForRowAtIndexPath:indexPath];
                    [actualCell.photoLabel setText:[NSString stringWithFormat:@"%d photo%@", number, number == 1 ? @"" : @"s"]];
                }];
            };
        }
    }

    cell.followButton.selected = NO;
    cell.tag = indexPath.row;
    
    if (self.followStatus == PAPFindFriendsFollowingSome) {
        if (attributes) {
            [cell.followButton setSelected:[[PAPCache sharedCache] followStatusForUser:(PFUser *)object]];
        } else {
            @synchronized(self) {
                NSNumber *outstandingQuery = [self.outstandingFollowQueries objectForKey:indexPath];
                if (!outstandingQuery) {
                    [self.outstandingFollowQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
                    [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
                    [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                    [isFollowingQuery whereKey:kPAPActivityToUserKey equalTo:object];
                    [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                    
                    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingFollowQueries removeObjectForKey:indexPath];
                            [[PAPCache sharedCache] setFollowStatus:(!error && number > 0) user:(PFUser *)object];
                        }
                        if (cell.tag == indexPath.row) {
                            [cell.followButton setSelected:(!error && number > 0)];
                        }
                    }];
                }
            }
        }
    } else {
        [cell.followButton setSelected:(self.followStatus == PAPFindFriendsFollowingAll)];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NextPageCellIdentifier = @"NextPageCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:NextPageCellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NextPageCellIdentifier];
        [cell.mainView setBackgroundColor:[UIColor whiteColor]];
        cell.hideSeparatorBottom = YES;
        cell.hideSeparatorTop = YES;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}


#pragma mark - PAPFindFriendsCellDelegate

- (void)cell:(PAPFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    NSLog(@"Presenting account view controller with user: %@", aUser);
    [accountViewController setUser:aUser];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(PAPFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    [self shouldToggleFollowFriendForCell:cellView];
}

#pragma mark - ()

- (void)inviteFriendsButtonAction:(id)sender {
    CONInviteFriendsViewController *inviteVC = [[CONInviteFriendsViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:inviteVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)search:(id)sender
{
    searchResults = [[NSMutableArray alloc] initWithCapacity:kSearchResultLimit];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.navigationController.navigationBar.frame))];
    searchBar.barTintColor = [UIColor darkGrayColor];
    [searchBar setShowsCancelButton:YES animated:YES];
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];

    self.tableView.tableHeaderView = searchBar;
    
    [searchBar becomeFirstResponder];
}

- (void)shouldToggleFollowFriendForCell:(PAPFindFriendsCell*)cell {
    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        // Unfollow
        cell.followButton.selected = NO;
        [PAPUtility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        cell.followButton.selected = YES;
        [PAPUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            } else {
                cell.followButton.selected = NO;
            }
        }];
    }
}

@end
