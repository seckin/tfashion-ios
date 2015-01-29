//
//  CONFollowersViewController.m
//  TFashion
//
//  Created by Utku Sakil on 1/29/15.
//
//

#import "CONFollowersViewController.h"
#import "PAPAccountViewController.h"
#import "PAPFindFriendsCell.h"
#import "AppDelegate.h"

@interface CONFollowersViewController () <PAPFindFriendsCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;

@end

@implementation CONFollowersViewController
@synthesize outstandingFollowQueries;
@synthesize outstandingCountQueries;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
//        self.objectsPerPage = 15;
        
        // The Loading text clashes with the dark Anypic design
        self.loadingViewEnabled = NO;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor blackColor]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    self.navigationItem.title = @"Followers";
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.separatorColor = [UIColor colorWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PAPFindFriendsCell heightForCell];
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [query includeKey:kPAPActivityFromUserKey];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    PFUser *user = [object valueForKey:kPAPActivityFromUserKey];
    
    [cell setUser:user];
    
    [cell.photoLabel setText:@"0 photos"];
    
    NSDictionary *attributes = [[PAPCache sharedCache] attributesForUser:user];
    
    if (attributes) {
        // set them now
        NSNumber *number = [[PAPCache sharedCache] photoCountForUser:user];
        [cell.photoLabel setText:[NSString stringWithFormat:@"%@ photo%@", number, [number intValue] == 1 ? @"": @"s"]];
    } else {
        @synchronized(self) {
            NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
            if (!outstandingCountQueryStatus) {
                [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                PFQuery *photoNumQuery = [PFQuery queryWithClassName:kPAPPhotoClassKey];
                [photoNumQuery whereKey:kPAPPhotoUserKey equalTo:user];
                [photoNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [photoNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    @synchronized(self) {
                        [[PAPCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:user];
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
    
    if (attributes) {
        [cell.followButton setSelected:[[PAPCache sharedCache] followStatusForUser:user]];
    } else {
        @synchronized(self) {
            NSNumber *outstandingQuery = [self.outstandingFollowQueries objectForKey:indexPath];
            if (!outstandingQuery) {
                [self.outstandingFollowQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
                [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
                [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                [isFollowingQuery whereKey:kPAPActivityToUserKey equalTo:user];
                [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                
                [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingFollowQueries removeObjectForKey:indexPath];
                        [[PAPCache sharedCache] setFollowStatus:(!error && number > 0) user:user];
                    }
                    if (cell.tag == indexPath.row) {
                        [cell.followButton setSelected:(!error && number > 0)];
                    }
                }];
            }
        }
    }
    
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
