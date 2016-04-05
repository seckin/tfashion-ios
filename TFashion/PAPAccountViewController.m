
#import "PAPAccountViewController.h"
#import "PAPPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPLoadMoreCell.h"
#import "UIImage+ImageEffects.h"
#import "PAPSettingsButtonItem.h"
#import "CONSettingsViewController.h"
#import "CONFollowersViewController.h"
#import "CONFollowingViewController.h"
#import "UIImageView+WebCache.h"

@interface PAPAccountViewController()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *followerCountButton;
@property (nonatomic, strong) UIButton *followingCountButton;
@property (nonatomic, strong) UIButton *reportButton;
@property (nonatomic, strong) UILabel *photoCountLabel;
@property (nonatomic, strong) UILabel *photoCountTextLabel;
@property (nonatomic, strong) UILabel *followingCountTextLabel;
@property (nonatomic, strong) UILabel *followerCountTextLabel;
@property (nonatomic, strong) TBActionSheet *popup;
@end

@implementation PAPAccountViewController
@synthesize headerView;
@synthesize user;
@synthesize followerCountButton;
@synthesize followingCountButton;
@synthesize reportButton;
@synthesize photoCountLabel;
@synthesize photoCountTextLabel;
@synthesize followingCountTextLabel;
@synthesize followerCountTextLabel;
@synthesize popup;

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

    //self.navigationItem.title = [NSString stringWithFormat:@"%@", self.user.username];
    self.navigationItem.title = [NSString stringWithFormat:@"Profile"];

    // Add Settings button
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 152.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.backgroundView = texturedBackgroundView;

    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake( 12.0f, 12.0f, 62.0f, 62.0f)];
    [self.headerView addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    CALayer *layer = [profilePictureImageView layer];
    layer.cornerRadius = 30.0f;
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 1.0f;

    if ([PAPUtility userHasProfilePictures:self.user]) {
        PFFile *imageFile = [self.user objectForKey:kPAPUserProfilePicMediumKey];
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView sd_setImageWithURL:[NSURL URLWithString:profilePictureImageView.file.url] placeholderImage:[UIImage imageNamed:@"AvatarPlaceholderBig.png"]];
    } else {
        profilePictureImageView.image = [PAPUtility defaultProfilePicture];
    }
    [profilePictureImageView loadInBackground];

    // Add a bottomBorder.
    CALayer *bottomBorder = [CALayer layer];
    
    bottomBorder.frame = CGRectMake(0.0f, 100.0f, headerView.frame.size.width, (1.0f / [UIScreen mainScreen].scale));
    
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    
    [headerView.layer addSublayer:bottomBorder];
    
    // Add a bottomBorderTwo.
    CALayer *bottomBorderTwo = [CALayer layer];
    
    bottomBorderTwo.frame = CGRectMake(0.0f, 145.0f, headerView.frame.size.width, (15.0f / [UIScreen mainScreen].scale));
    
    bottomBorderTwo.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    
    [headerView.layer addSublayer:bottomBorderTwo];
    
    photoCountTextLabel = [[UILabel alloc] initWithFrame:CGRectMake( 12.0f, 120.0f, 92.0f, 22.0f)];
    [photoCountTextLabel  setTextAlignment:NSTextAlignmentLeft];
    [photoCountTextLabel  setBackgroundColor:[UIColor clearColor]];
    [photoCountTextLabel  setTextColor:[UIColor blackColor]];
    [photoCountTextLabel  setFont:[UIFont fontWithName:@"Gotham-Medium" size:12.0f]];
    [self.headerView addSubview:photoCountTextLabel ];
    [photoCountTextLabel setText:@"Photos"];
    
    photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 12.0f, 105.0f, 92.0f, 22.0f)];
    [photoCountLabel setTextAlignment:NSTextAlignmentLeft];
    [photoCountLabel setBackgroundColor:[UIColor clearColor]];
    [photoCountLabel setTextColor:[UIColor blackColor]];
    [photoCountLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:20.0f]];
    [self.headerView addSubview:photoCountLabel];
    [photoCountLabel setText:@"0"];
    
    followerCountTextLabel = [[UILabel alloc] initWithFrame:CGRectMake( 135.0f, 120.0f, 226.0f - 130.0f, 22.0f)];
    [followerCountTextLabel  setTextAlignment:NSTextAlignmentLeft];
    [followerCountTextLabel  setBackgroundColor:[UIColor clearColor]];
    [followerCountTextLabel  setTextColor:[UIColor blackColor]];
    [followerCountTextLabel  setFont:[UIFont fontWithName:@"Gotham-Medium" size:12.0f]];
    [self.headerView addSubview:followerCountTextLabel ];
    [followerCountTextLabel setText:@"Followers"];
    
    followerCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [followerCountButton setFrame:CGRectMake( 94.0f, 105.0f, 226.0f - 130.0f, 22.0f)];
    [followerCountButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [followerCountButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [followerCountButton.titleLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:20.0f]];
    [followerCountButton addTarget:self action:@selector(followerCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:followerCountButton];
    
    followingCountTextLabel = [[UILabel alloc] initWithFrame:CGRectMake( 245.0f, 120.0f, self.headerView.bounds.size.width - 245.0f, 22.0f)];
    [followingCountTextLabel  setTextAlignment:NSTextAlignmentLeft];
    [followingCountTextLabel  setBackgroundColor:[UIColor clearColor]];
    [followingCountTextLabel  setTextColor:[UIColor blackColor]];
    [followingCountTextLabel  setFont:[UIFont fontWithName:@"Gotham-Medium" size:12.0f]];
    [self.headerView addSubview:followingCountTextLabel ];
    [followingCountTextLabel setText:@"Following"];
    
    followingCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [followingCountButton setFrame:CGRectMake( 214.0f, 105.0f, self.headerView.bounds.size.width - 245.0f, 22.0f)];
    [followingCountButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [followingCountButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [followingCountButton.titleLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:20.0f]];
    [followingCountButton addTarget:self action:@selector(followingCountButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:followingCountButton];

    UILabel *userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, 10.0f, self.headerView.bounds.size.width, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentLeft];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor blackColor]];
    [userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    [userDisplayNameLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:16.0f]];
    [self.headerView addSubview:userDisplayNameLabel];
    
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, 30.0f, self.headerView.bounds.size.width, 22.0f)];
    [usernameLabel setTextAlignment:NSTextAlignmentLeft];
    [usernameLabel setBackgroundColor:[UIColor clearColor]];
    [usernameLabel setTextColor:[UIColor colorWithRed:239.0f/255.0f green:53.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
    [usernameLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:12.0f]];
    [usernameLabel setText:[NSString stringWithFormat:@"@%@", [self.user objectForKey:@"username"]]];
    [self.headerView addSubview:usernameLabel];

    // report
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        self.reportButton = [[UIButton alloc] initWithFrame:CGRectMake( self.headerView.bounds.size.width - 50, 12.0f, 62.0f, 30.0f)];
        float ellipsisiconsize = 16.0f;
        FAKFontAwesome *plusIcon = [FAKFontAwesome ellipsisHIconWithSize:ellipsisiconsize];
        [plusIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        [self.reportButton setOpaque:YES];
        [self.reportButton setImage:[plusIcon imageWithSize:CGSizeMake(ellipsisiconsize, ellipsisiconsize)] forState:UIControlStateNormal];
        [self.reportButton setImage:[plusIcon imageWithSize:CGSizeMake(ellipsisiconsize, ellipsisiconsize)]
                           forState:UIControlStateSelected];
        [self.reportButton setTitle:@""
                           forState:UIControlStateNormal];
        [self.reportButton setTitle:@""
                           forState:UIControlStateSelected];
        [self.reportButton setTitleColor:[UIColor blackColor]
                                forState:UIControlStateNormal];
        [self.reportButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateSelected];
        [self.reportButton addTarget:self action:@selector(didTapReportButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];

        [self.headerView addSubview:self.reportButton];
    }


    if([self.user objectForKey:@"location"] && [[self.user objectForKey:@"location"] length] > 0) {
        // add location icon
        float locationButtonIconSize = 20.0f;
        UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [locationButton setFrame:CGRectMake(83.0, 52.0f, locationButtonIconSize, locationButtonIconSize)];
        [locationButton setBackgroundColor:[UIColor clearColor]];
        FAKIonIcons *locationIcon = [FAKIonIcons iosLocationIconWithSize:locationButtonIconSize];
        [locationIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:53.0f / 255.0f green:60.0f / 255.0f blue:65.0f / 255.0f alpha:0.8f]];
        [locationButton setBackgroundImage:[locationIcon imageWithSize:CGSizeMake(locationButtonIconSize, locationButtonIconSize)] forState:UIControlStateNormal];
        [locationButton setSelected:NO];
        [self.headerView addSubview:locationButton];

        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(103, 52.0f, self.headerView.bounds.size.width, 22.0f)];
        [locationLabel setTextAlignment:NSTextAlignmentLeft];
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        [locationLabel setTextColor:[UIColor colorWithRed:53.0f / 255.0f green:60.0f / 255.0f blue:65.0f / 255.0f alpha:1.0f]];
        [locationLabel setText:[self.user objectForKey:@"location"]];
        [locationLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:12.0f]];
        [self.headerView addSubview:locationLabel];
    }

    if([self.user objectForKey:@"isSister"]) {
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(88.0, 77.0, 85, 18.0f)];
        [myLabel setText:@"💃Sister💃"];
        myLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:12.0f];
        [myLabel sizeThatFits:CGSizeMake(16, 16)];
        myLabel.layer.borderColor = [UIColor colorWithRed:239.0f / 255.0f green:53.0f / 255.0f blue:103.0f / 255.0f alpha:1.0f].CGColor;
        myLabel.textColor = [UIColor colorWithRed:239.0f / 255.0f green:53.0f / 255.0f blue:103.0f / 255.0f alpha:1.0f];
        myLabel.textAlignment = NSTextAlignmentCenter;
        myLabel.layer.borderWidth = 1.0;
        myLabel.layer.cornerRadius = 3.0;
        [self.headerView addSubview:myLabel];
    }

    [followerCountButton setTitle:@"0" forState:UIControlStateNormal];
    
    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followerCountButton setTitle:[NSString stringWithFormat:@"%d%@", number, number==1?@"":@""] forState:UIControlStateNormal];
        }
    }];

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

- (BFTask<NSArray<__kindof PFObject *> *> *)loadObjects
{
    BFTask<NSArray<__kindof PFObject *> *> *ret = [super loadObjects];
    
    [self queryForFollowingCount];
    [self queryForFollowerCount];
    [self queryForPhotoCount];
    return ret;
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
            [photoCountLabel setText:[NSString stringWithFormat:@"%d", number, number==1?@"":@"s"]];
            [[PAPCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
        }
    }];
}

- (void)queryForFollowingCount
{
    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
    if (followingDictionary) {
        [followingCountButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)[[followingDictionary allValues] count]] forState:UIControlStateNormal];
    }
    
    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followingCountButton setTitle:[NSString stringWithFormat:@"%d", number] forState:UIControlStateNormal];
        }
    }];
}

- (void)queryForFollowerCount
{
    NSDictionary *followerDictionary = [[PFUser currentUser] objectForKey:@"followers"];
    if (followerDictionary) {
        [followerCountButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)[[followerDictionary allValues] count]] forState:UIControlStateNormal];
    }

    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followerCountButton setTitle:[NSString stringWithFormat:@"%d", number] forState:UIControlStateNormal];
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
    CONFollowersViewController *followersVC = [[CONFollowersViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:followersVC animated:YES];
}

- (void)followingCountButtonAction:(id)sender
{
    CONFollowingViewController *followingVC = [[CONFollowingViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:followingVC animated:YES];
}


- (void)didTapReportButtonAction:(UIButton *)sender {
    self.popup = [[TBActionSheet alloc] init];
    self.popup.delegate = self;
    self.popup.title = @"Select an option:";
    [self.popup addButtonWithTitle:@"Block"];
    self.popup.cancelButtonIndex = [self.popup addButtonWithTitle:@"Cancel"];

    popup.tag = 1;
    UIViewController *vc = (UIViewController *)[self getViewController];
    [self.popup showInView:vc.view];
}

- (UIViewController *)getViewController
{
    id vc = [self nextResponder];
    while(![vc isKindOfClass:[UIViewController class]] && vc!=nil)
    {
        vc = [vc nextResponder];
    }

    return vc;
}

- (void)actionSheet:(TBActionSheet *)sheetpopup clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (sheetpopup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"button index 0 clicked");
                    [self saveBlock];
                    break;
                case 1:
                    NSLog(@"button index 1 clicked - cancel button");
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)saveBlock {
    PFObject *report = [PFObject objectWithClassName:kPAPReportClassKey];

    [report setObject:self.user forKey:kPAPReportToUserKey];
    [report setObject:[PFUser currentUser] forKey:kPAPReportFromUserKey];
//    [report setObject:nil forKey:kPAPReportPhotoKey];
    [report saveEventually];
    [TSMessage showNotificationWithTitle:@"User blocked" type:TSMessageNotificationTypeSuccess];

    [self configureFollowButton];
    [PAPUtility unfollowUserEventually:self.user];
}

@end