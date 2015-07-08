//
//  CONV2IntroViewController.m
//  TFashion
//
//  Created by Seckin Can Sahin on 6/28/15.
//
//

#import "CONV2IntroViewController.h"
#import "PAPLogInViewController.h"
#import "AppDelegate.h"
#import "CONSocialAccount.h"

@interface CONV2IntroViewController () {
    BOOL _presentedLoginViewController;
    int _facebookResponseCount;
    int _expectedFacebookResponseCount;
    NSMutableData *_profilePicData;
}

@end

@implementation CONV2IntroViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) {
        return;
    }
    
    // Present Anypic UI
    [(AppDelegate *) [[UIApplication sharedApplication] delegate] presentTabBarController];
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    _facebookResponseCount = 0;
    [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CONV2IntroViewController

- (IBAction)signUpButtonHandler:(id)sender {
    if (_presentedLoginViewController) {
        return;
    }
    
    _presentedLoginViewController = YES;
    PAPLogInViewController *loginViewController = [[PAPLogInViewController alloc] init];
    loginViewController.delegate = self;
    [self presentViewController:loginViewController animated:NO completion:nil];
}

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    // This fetches the most recent data from FB, and syncs up all data with the server including profile pic and friends list from FB.
    
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
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
        // refreshed
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

- (void)processedFacebookResponse {
    // Once we handled all necessary facebook batch responses, save everything necessary and continue
    @synchronized (self) {
        _facebookResponseCount++;
        if (_facebookResponseCount != _expectedFacebookResponseCount) {
            return;
        }
    }
    _facebookResponseCount = 0;
    NSLog(@"done processing all Facebook requests");
    
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
