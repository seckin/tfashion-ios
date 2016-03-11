//
//  PAPWelcomeViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/10/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

//#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "PAPWelcomeViewController.h"
#import "AppDelegate.h"
#import "CONSocialAccount.h"
#import "Bugsnag.h"
#import <StandoutModule-Swift.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface PAPWelcomeViewController () {
    BOOL _presentedLoginViewController;
    BOOL _presentedBrowserController;
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
    [Bugsnag leaveBreadcrumbWithMessage:@"welcomecontroller viewdidappear"];
    
    if(self.firstLaunch) {
        NSLog(@"welcomeviewcontroller self.firstLaunch: true");
    } else {
        NSLog(@"welcomeviewcontroller self.firstLaunch: false");
    }
    
    if(self.firstLaunch) {
        NSLog(@"welcome first launch");
        [self presentBrowserController:NO];
        return;
    }

    if (![PFUser currentUser]) {
        [self presentLoginViewController:NO];
        return;
    }

    // Present Anypic UI
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] presentTabBarController];

    // Refresh current user with server side data -- checks if user is still valid and so on
    _facebookResponseCount = 0;
    [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}


#pragma mark - PAPWelcomeViewController

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
            NSLog(@"Failed save in background of user, %@", error);
        } else {
            NSLog(@"saved current parse user");
            if ([PAPUtility userHasValidFacebookData:currentParseUser] && currentParseUser.isNew) {
                CONSocialAccount *socialAccount = [CONSocialAccount object];
                socialAccount.isActive = YES;
                socialAccount.type = kSocialAccountTypeFacebook;
                socialAccount.ownerUser = currentParseUser;
                socialAccount.providerId = [currentParseUser valueForKey:kPAPUserFacebookIDKey];
                socialAccount.providerUsername = [currentParseUser valueForKey:kPAPUserEmailKey];
                socialAccount.providerDisplayName = [currentParseUser valueForKey:kPAPUserDisplayNameKey];
                socialAccount.scope = [[PFFacebookUtils session] permissions];
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

    FBSession *session = [PFFacebookUtils session];
//    if (!session.isOpen) {
//        NSLog(@"FB Session does not exist, logout");
//        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
//        return;
//    }

//    if (!session.accessTokenData.userID) {
//        NSLog(@"userID on FB Session does not exist, logout");
//        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
//        return;
//    }

    PFUser *currentParseUser = [PFUser currentUser];
    if (!currentParseUser) {
        NSLog(@"Current Parse user does not exist, logout");
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
        return;
    }

    NSString *facebookId = [currentParseUser objectForKey:kPAPUserFacebookIDKey];
    if (!facebookId || ![facebookId length]) {
        // set the parse user's FBID
        [currentParseUser setObject:session.accessTokenData.userID forKey:kPAPUserFacebookIDKey];
    }

    if (![PAPUtility userHasValidFacebookData:currentParseUser]) {
        NSLog(@"User does not have valid facebook ID. PFUser's FBID: %@, FBSessions FBID: %@. logout", [currentParseUser objectForKey:kPAPUserFacebookIDKey], session.accessTokenData.userID);
        [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
        return;
    }

    // Finished checking for invalid stuff
    // Refresh FB Session (When we link up the FB access token with the parse user, information other than the access token string is dropped
    // By going through a refresh, we populate useful parameters on FBAccessTokenData such as permissions.
    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            NSLog(@"Failed refresh of FB Session, logging out: %@", error);
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] logOut];
            return;

        }
        NSLog(@"refreshed permissions: %@", session);

        _expectedFacebookResponseCount = 0;
        NSArray *permissions = [[session accessTokenData] permissions];
        if ([permissions containsObject:@"public_profile"]) {
            // Logged in with FB
            // Create batch request for all the stuff
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            _expectedFacebookResponseCount++;
            [connection addRequest:[FBRequest requestForMe] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
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

                [self processedFacebookResponse];

            }];

            // profile pic request
            _expectedFacebookResponseCount++;
            [connection addRequest:[FBRequest requestWithGraphPath:@"me" parameters:@{@"fields" : @"picture.width(500).height(500)"} HTTPMethod:@"GET"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *) result;

                    NSURL *profilePictureURL = [NSURL URLWithString:userData[@"picture"][@"data"][@"url"]];
                    NSLog(@"profilePictureURL: %@", profilePictureURL);
//                    NSString *substring = [userData[@"picture"][@"data"][@"url"] substringFromIndex:7];
//                    NSString *prefix = @"https://s3.amazonaws.com/";
//                    NSString *profilePictureURL = [prefix stringByAppendingString:substring];

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
            if ([permissions containsObject:@"user_friends"]) {
                // Fetch FB Friends + me
                _expectedFacebookResponseCount++;
                [connection addRequest:[FBRequest requestForMyFriends] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    NSLog(@"processing Facebook friends");
                    if (error) {
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
            [connection start];
        } else {
            NSData *profilePictureData = UIImagePNGRepresentation([UIImage imageNamed:@"AvatarPlaceholder.png"]);
            [PAPUtility processFacebookProfilePictureData:profilePictureData];

            [[PAPCache sharedCache] clear];
            [currentParseUser setObject:@"Someone" forKey:kPAPUserDisplayNameKey];
            _expectedFacebookResponseCount++;
            [self processedFacebookResponse];

        }


    }];

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
