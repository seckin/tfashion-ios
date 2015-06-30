//
//  PAPAccountViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/2/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPAccountViewController.h"
#import "PAPPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPLoadMoreCell.h"
#import "UIImage+ImageEffects.h"
#import "PAPSettingsButtonItem.h"
#import "CONSettingsViewController.h"
#import "CONFollowersViewController.h"
#import "CONFollowingViewController.h"

@interface PAPAccountViewController()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *followerCountButton;
@property (nonatomic, strong) UIButton *followingCountButton;
@property (nonatomic, strong) UILabel *photoCountLabel;
@end

@implementation PAPAccountViewController
@synthesize headerView;
@synthesize user;
@synthesize followerCountButton;
@synthesize followingCountButton;
@synthesize photoCountLabel;

#pragma mark - Initialization

- (id)initWithUser:(PFUser *)aUser {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.user = aUser;

        if (!aUser) {
            [NSException raise:NSInvalidArgumentException format:@"PAPAccountViewController init exception: user cannot be nil"];
        }

    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.user) {
        self.user = [PFUser currentUser];
        [[PFUser currentUser] fetchIfNeeded];
    }

//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.user.username];
    
    // Add Settings button
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 222.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on

    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor lightGrayColor]];
    self.tableView.backgroundView = texturedBackgroundView;

    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 94.0f, 38.0f, 132.0f, 132.0f)];
    [self.headerView addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    profilePictureImageView.alpha = 1.0f;

    if ([PAPUtility userHasProfilePictures:self.user]) {
        PFFile *imageFile = [self.user objectForKey:kPAPUserProfilePicMediumKey];
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
        }];
    } else {
        profilePictureImageView.image = [PAPUtility defaultProfilePicture];
    }
    
    UIImageView *photoCountIconImageView = [[UIImageView alloc] initWithImage:nil];
    FAKIonIcons *iconImages = [FAKIonIcons imagesIconWithSize:45.0f];
    [iconImages addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [photoCountIconImageView setImage:[iconImages imageWithSize:CGSizeMake(45.0f, 37.0f)]];
    [photoCountIconImageView setFrame:CGRectMake( 26.0f, 50.0f, 45.0f, 37.0f)];
    [self.headerView addSubview:photoCountIconImageView];
    
    photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 94.0f, 92.0f, 22.0f)];
    [photoCountLabel setTextAlignment:NSTextAlignmentCenter];
    [photoCountLabel setBackgroundColor:[UIColor clearColor]];
    [photoCountLabel setTextColor:[UIColor whiteColor]];
    [photoCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [self.headerView addSubview:photoCountLabel];
    
    UIImageView *followersIconImageView = [[UIImageView alloc] initWithImage:nil];
    FAKIonIcons *followersIcon = [FAKIonIcons iosPeopleIconWithSize:52.0f];
    [followersIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [followersIconImageView setImage:[followersIcon imageWithSize:CGSizeMake(52.0f, 37.0f)]];
    [followersIconImageView setFrame:CGRectMake( 247.0f, 50.0f, 52.0f, 37.0f)];
    [self.headerView addSubview:followersIconImageView];
    
    followerCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [followerCountButton setFrame:CGRectMake( 226.0f, 94.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
    [followerCountButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [followerCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [followerCountButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [followerCountButton addTarget:self action:@selector(followerCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:followerCountButton];
    
    followingCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [followingCountButton setFrame:CGRectMake( 226.0f, 110.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
    [followingCountButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [followingCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [followingCountButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [followingCountButton addTarget:self action:@selector(followingCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:followingCountButton];
    
    UILabel *userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 176.0f, self.headerView.bounds.size.width, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentCenter];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor whiteColor]];
    [userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    [userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.headerView addSubview:userDisplayNameLabel];
    
    [photoCountLabel setText:@"0 photos"];
    
//    [self queryForPhotoCount];
    
    [followerCountButton setTitle:@"0 followers" forState:UIControlStateNormal];
    
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followerCountButton setTitle:[NSString stringWithFormat:@"%d follower%@", number, number==1?@"":@"s"] forState:UIControlStateNormal];
        }
    }];
    
//    [self queryForFollowingCount];
    
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                NSLog(@"Couldn't determine follow relationship: %@", error);
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    [self configureFollowButton];
                } else {
                    [self configureUnfollowButton];
                }
            }
        }];
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    self.tableView.tableHeaderView = headerView;
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kPAPPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kPAPPhotoUserKey];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (void)loadObjects
{
    [super loadObjects];
    
    [self queryForFollowingCount];
    [self queryForPhotoCount];
}

#pragma mark - ()

- (void)userFollowingChanged:(NSNotification *)note
{
    [self queryForFollowingCount];
}

- (void)queryForPhotoCount
{
    PFQuery *queryPhotoCount = [PFQuery queryWithClassName:@"Photo"];
    [queryPhotoCount whereKey:kPAPPhotoUserKey equalTo:self.user];
    [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [photoCountLabel setText:[NSString stringWithFormat:@"%d photo%@", number, number==1?@"":@"s"]];
            [[PAPCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
        }
    }];
}

- (void)queryForFollowingCount
{
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    if (followingDictionary) {
        [followingCountButton setTitle:[NSString stringWithFormat:@"%lu following", (unsigned long)[[followingDictionary allValues] count]] forState:UIControlStateNormal];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followingCountButton setTitle:[NSString stringWithFormat:@"%d following", number] forState:UIControlStateNormal];
        }
    }];
}

- (void)settingsButtonAction:(id)sender {
    CONSettingsViewController *settingsVC = [[CONSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureUnfollowButton];

    [PAPUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureFollowButton];

    [PAPUtility unfollowUserEventually:self.user];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureFollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStylePlain target:self action:@selector(followButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStylePlain target:self action:@selector(unfollowButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:YES user:self.user];
}

- (void)followerCountButtonAction:(id)sender
{
    CONFollowersViewController *followersVC = [[CONFollowersViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:followersVC animated:YES];
}

- (void)followingCountButtonAction:(id)sender
{
    CONFollowingViewController *followingVC = [[CONFollowingViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:followingVC animated:YES];
}

@end