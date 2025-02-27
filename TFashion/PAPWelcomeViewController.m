
#import "PAPWelcomeViewController.h"
#import "AppDelegate.h"
#import "CONSocialAccount.h"
#import "CONForceFollowViewController.h"
#import <StandoutModule-Swift.h>

@interface PAPWelcomeViewController () {
    BOOL _presentedLoginViewController;
    BOOL _presentedBrowserController;
    BOOL _presentedForceFollowController;
    int _facebookResponseCount;
    int _expectedFacebookResponseCount;
    NSMutableData *_profilePicData;
}

@property (nonatomic, strong) ActivityViewController *a;
@property (nonatomic, strong) ActivityViewController2 *a2;
@property (nonatomic, strong) ActivityViewController3 *a3;
@property (nonatomic, strong) ActivityViewController4 *a4;

@end

@implementation PAPWelcomeViewController
@synthesize firstLaunch;

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [backgroundImageView setImage:[UIImage imageNamed:@"BackgroundLogin.png"]];
    self.view = backgroundImageView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if(self.firstLaunch) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"needToShowForceFollowController"];
        [self presentBrowserController:NO];
        return;
    }

    if (![PFUser currentUser]) {
        [self presentLoginViewController:NO];
        return;
    }

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"needToShowForceFollowController"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"needToShowForceFollowController"];
        [self presentForceFollowController:NO];
    }

    // Present Anypic UI
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] presentTabBarController];

    // Refresh current user with server side data -- checks if user is still valid and so on
    _facebookResponseCount = 0;
    [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}


#pragma mark - PAPWelcomeViewController

- (void)presentForceFollowController:(BOOL)animated {
    if(_presentedForceFollowController) {
        return;
    }

    _presentedLoginViewController = YES;
    CONForceFollowViewController *forceFollowViewController = [[CONForceFollowViewController alloc] init];
    [self presentViewController:forceFollowViewController animated:NO completion:nil];
}

- (void)presentBrowserController:(BOOL)animated {
    if (_presentedBrowserController) {
        return;
    }
    
    _presentedBrowserController = YES;
    firstLaunch = false;
    self.a = [[ActivityViewController alloc] init];
    self.a2 = [[ActivityViewController2 alloc] init];
    self.a3 = [[ActivityViewController3 alloc] init];
    self.a4 = [[ActivityViewController4 alloc] init];
    
    BrowserViewController *b = [[BrowserViewController alloc] initWithViewControllers:@[self.a, self.a2, self.a3, self.a4]];

    [self presentViewController:b animated:animated completion:nil];
}

- (void)presentLoginViewController:(BOOL)animated {
    if (_presentedLoginViewController) {
        return;
    }

    _presentedLoginViewController = YES;
    PAPLogInViewController *loginViewController = [[PAPLogInViewController alloc] init];
    loginViewController.delegate = self;
    [self presentViewController:loginViewController animated:animated completion:nil];
}


#pragma mark - PAPLoginViewControllerDelegate

- (void)logInViewControllerDidLogUserIn:(PAPLogInViewController *)logInViewController {
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kPAPInstallationUserKey];
    
    if (_presentedLoginViewController) {
        _presentedLoginViewController = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - ()

- (void)processedFacebookResponse {
    // Once we handled all necessary facebook batch responses, save everything necessary and continue
    @synchronized (self) {
        _facebookResponseCount++;
        if (_facebookResponseCount != _expectedFacebookResponseCount) {
            return;
        }
    }
    _facebookResponseCount = 0;

    PFUser *currentParseUser = [PFUser currentUser];

    [currentParseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"processedFacebookResponse - Failed save in background of user, %@", error);
        } else {
            NSLog(@"processedFacebookResponse - saved current parse user");
            if ([PAPUtility userHasValidFacebookData:currentParseUser] && currentParseUser.isNew) {
                CONSocialAccount *socialAccount = [CONSocialAccount object];
                socialAccount.isActive = YES;
                socialAccount.type = kSocialAccountTypeFacebook;
                socialAccount.ownerUser = currentParseUser;
                socialAccount.providerId = [currentParseUser valueForKey:kPAPUserFacebookIDKey];
                socialAccount.providerUsername = [currentParseUser valueForKey:kPAPUserEmailKey];
                socialAccount.providerDisplayName = [currentParseUser valueForKey:kPAPUserDisplayNameKey];
//                socialAccount.scope = [[PFFacebookUtils session] permissions];
                [socialAccount saveInBackground];
            }
        }
    }];
}

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    // This fetches the most recent data from FB, and syncs up all data with the server including profile pic and friends list from FB.
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
        return;
    }

    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    if (!accessToken) {
        NSLog(@"FB Session does not exist, logout");
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
        return;
    }

    if (!accessToken.userID) {
        NSLog(@"userID on FB Session does not exist, logout");
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
        return;
    }

    PFUser *currentParseUser = [PFUser currentUser];
    if (!currentParseUser) {
        NSLog(@"Current Parse user does not exist, logout");
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
        return;
    }

    NSString *facebookId = [currentParseUser objectForKey:kPAPUserFacebookIDKey];
    if (!facebookId || ![facebookId length]) {
        // set the parse user's FBID
        [currentParseUser setObject:accessToken.userID forKey:kPAPUserFacebookIDKey];
    }

    if (![PAPUtility userHasValidFacebookData:currentParseUser]) {
        NSLog(@"User does not have valid facebook ID. PFUser's FBID: %@, FBSessions FBID: %@. logout", [currentParseUser objectForKey:kPAPUserFacebookIDKey], accessToken.userID);
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email,location" forKey:@"fields"];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error) {
            // Failed to fetch me data.. logout to be safe
            NSLog(@"couldn't fetch facebook /me data: %@, logout", error);
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
            return;
        }
        
        NSString *facebookName = result[@"name"];
        if (facebookName && [facebookName length] != 0) {
            [currentParseUser setObject:facebookName forKey:kPAPUserDisplayNameKey];
            
            NSArray *nameparts = [facebookName componentsSeparatedByString:@" "];
            NSString *concatanatedName = [nameparts componentsJoinedByString:@""];
            NSString *lowercaseconcatanatedName = [concatanatedName lowercaseString];
            [currentParseUser setObject:[NSNumber numberWithBool:YES] forKey:kPAPUserDidUpdateUsernameKey];
            [currentParseUser setUsername:lowercaseconcatanatedName];
        }
        
        NSString *email = result[@"email"];
        if (email && [email length] != 0) {
            [currentParseUser setObject:email forKey:kPAPUserEmailKey];
        }

        if(result[@"location"]) {
            NSString *location = result[@"location"][@"name"];
            if (location && [location length] != 0) {
                [currentParseUser setObject:location forKey:kPAPUserLocationKey];
            }
        }
        
        [self processedFacebookResponse];
    }];
    
    FBSDKGraphRequest *request2 = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:@{@"fields" : @"picture.width(500).height(500)"}];
    [request2 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *) result;
            
            NSURL *profilePictureURL = [NSURL URLWithString:userData[@"picture"][@"data"][@"url"]];

            // Now add the data to the UI elements
            NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
            [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
        } else {
            NSLog(@"Error getting profile pic url, setting as default avatar: %@", error);
            NSData *profilePictureData = UIImagePNGRepresentation([UIImage imageNamed:@"AvatarPlaceholder.png"]);
            [PAPUtility processFacebookProfilePictureData:profilePictureData];
        }
        [self processedFacebookResponse];
    }];
    
    if ([accessToken.permissions containsObject:@"user_friends"]) {
        FBSDKGraphRequest *request3 = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                       parameters:nil];
        [request3 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            NSLog(@"processing Facebook friends");
            if (error) {
                // *** TODO: only clear facebook friends, not the all cache
                // just clear the FB friend cache
                [[PAPCache sharedCache] clear];
            } else {
                NSArray *data = [result objectForKey:@"data"];
                NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
                for (NSDictionary *friendData in data) {
                    if (friendData[@"id"]) {
                        [facebookIds addObject:friendData[@"id"]];
                    }
                }
                // cache friend data
                [[PAPCache sharedCache] setFacebookFriends:facebookIds];
                
                if ([currentParseUser objectForKey:kPAPUserFacebookFriendsKey]) {
                    [currentParseUser removeObjectForKey:kPAPUserFacebookFriendsKey];
                }
                if ([currentParseUser objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
                    [(AppDelegate *) [[UIApplication sharedApplication] delegate] autoFollowUsers];
                    
                }
            }
            [self processedFacebookResponse];
        }];
    }

}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _profilePicData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_profilePicData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [PAPUtility processFacebookProfilePictureData:_profilePicData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error downloading profile pic data: %@", error);
}


@end
