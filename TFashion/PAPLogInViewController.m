//
//  PAPLogInViewController.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPLogInViewController.h"
#import "CONSignUpViewController.h"
#import "AppDelegate.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "MBProgressHUD.h"
#import "Bugsnag.h"

@interface PAPLogInViewController() {
    FBLoginView *_facebookLoginView;
    PFLogInView *_logInView;
    UILabel *appName;
    UILabel *appIntro;
}

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@interface FBSession (Private)

- (void)clearAffinitizedThread;

@end

@implementation PAPLogInViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchBackGround.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchBackGround.png"]];
    }


    appName = [[UILabel alloc] init];
    [appName setText: @"Standout"];
    [appName setTextColor:[UIColor whiteColor]];
    [appName setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [appName setFrame:CGRectMake(100, 75, 200, 50)];
    [self.view addSubview:appName];

    appIntro = [[UILabel alloc] init];
//    [appIntro setText: @"A community of tastemakers sharing pictures of clothes. Share your clothes to get them tagged so other users can double tap on them to like and comment!"];
    [appIntro setTextColor:[UIColor whiteColor]];
    [appIntro setFont:[UIFont systemFontOfSize:14.0f]];
    [appIntro setFrame:CGRectMake(50, 340, 220, 100)];
    appIntro.lineBreakMode = NSLineBreakByWordWrapping;
    appIntro.numberOfLines = 0;
    [self.view addSubview:appIntro];

    //Position of the Facebook button
    CGFloat yPosition = 360.0f;
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        yPosition = 450.0f;
    }
    _facebookLoginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"user_friends", @"email"]];//, @"user_photos"]];
    _facebookLoginView.frame = CGRectMake(36.0f, yPosition, 244.0f, 44.0f);
    _facebookLoginView.delegate = self;
    _facebookLoginView.tooltipBehavior = FBLoginViewTooltipBehaviorDisable;
    [self.view addSubview:_facebookLoginView];

//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    loginButton.center = self.view.center;
//    loginButton.delegate = self;
//    [self.view addSubview:loginButton];
    
    // Sign up button
    _logInView = [[PFLogInView alloc] initWithFields:PFLogInFieldsSignUpButton];
    _logInView.backgroundColor = [UIColor clearColor];
    _logInView.frame = CGRectMake(20.0f, CGRectGetMaxY(_facebookLoginView.frame) + 10, 276.0f, 62.0f);
    [self.view addSubview:_logInView];

    NSArray *signUpButtonActions = [_logInView.signUpButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    for (int i = 0; i<signUpButtonActions.count; i++) {
        SEL oldAction = NSSelectorFromString(signUpButtonActions[i]);
        [_logInView.signUpButton removeTarget:self action:oldAction forControlEvents:UIControlEventTouchUpInside];
    }
    [_logInView.signUpButton addTarget:self action:@selector(showSignUpController:) forControlEvents:UIControlEventTouchUpInside];
    [_logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [_logInView.signUpButton setTitle:@"Sign Up With Text" forState:UIControlStateNormal];
    [_logInView.signUpButton setFont:[UIFont boldSystemFontOfSize:16]];
    _logInView.signUpButton.layer.cornerRadius = 10;
    _logInView.signUpButton.layer.borderWidth = 3;
    _logInView.signUpButton.layer.borderColor = [UIColor whiteColor].CGColor;


    // disabled for now:
//     Test login button
//    UIButton *testLoginButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [testLoginButton setTitle:@"Test Login" forState:UIControlStateNormal];
//    [testLoginButton setFrame:CGRectMake(36.0f, CGRectGetMinY(_facebookLoginView.frame) - 53, 244.0f, 42.0f)];
//    testLoginButton.clipsToBounds = YES;
//    testLoginButton.layer.cornerRadius = 3;
//    [testLoginButton setBackgroundColor:[UIColor orangeColor]];
//    [testLoginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [testLoginButton addTarget:self action:@selector(testLoginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:testLoginButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Action

- (void)testLoginButtonAction:(id)sender
{
    PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
    logInController.delegate = self;
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void)showSignUpController:(id)sender
{
    CONSignUpViewController *signUpController = [[CONSignUpViewController alloc] init];
    signUpController.fields = PFSignUpFieldsDismissButton | PFSignUpFieldsSignUpButton;
    signUpController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self presentViewController:signUpController animated:YES completion:nil];
}

#pragma mark - PFLoginViewControllerDelegate - TEST LOGIN

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [user setObject:user.username forKey:kPAPUserDisplayNameKey];
    [user setObject:[self getProfilePictureIsSmall:NO] forKey:kPAPUserProfilePicMediumKey];
    [user setObject:[self getProfilePictureIsSmall:YES] forKey:kPAPUserProfilePicSmallKey];
    [user setObject:[NSNumber numberWithBool:YES] forKey:kPAPUserDidUpdateUsernameKey];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if ([self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
                [self.delegate performSelector:@selector(logInViewControllerDidLogUserIn:) withObject:user];
            }
        }
    }];
}

- (PFFile *)getProfilePictureIsSmall:(BOOL)isSmall
{
    PFFile *file = nil;
    if (isSmall) {
        UIImage *image = [UIImage imageNamed:@"profilePictureSmall"];
        NSData *data = UIImagePNGRepresentation(image);
        file = [PFFile fileWithData:data];
    } else {
        UIImage *image = [UIImage imageNamed:@"profilePictureMedium"];
        NSData *data = UIImageJPEGRepresentation(image, 0.5);
        file = [PFFile fileWithData:data];
    }
    
    return file;
}

//#pragma mark - FBSDKLoginButtonDelegate
//
//- (void) loginButton: (FBSDKLoginButton *)loginButton
//    didCompleteWithResult:	(FBSDKLoginManagerLoginResult *)result
//    error:	(NSError *)error {
//    NSLog(@"FBSDKLoginButtonDelegate login result %@", result);
//}
//
//- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
//    NSLog(@"FBSDKLoginButtonDelegate logout called");
//}

#pragma mark - FBLoginViewDelegate

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    [self handleFacebookSessionWithUser:user];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSLog(@"entered: loginView:(FBLoginView *)loginView handleError");
    [self handleLogInError:error];
}

- (void)handleFacebookSessionWithUser:(id<FBGraphUser>)user  {
    NSLog(@"entered: handleFacebookSessionWithUser user:%@", user);
    if ([PFUser currentUser]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginViewControllerDidLogUserIn:)]) {
            [self.delegate performSelector:@selector(logInViewController:didLogInUser:) withObject:[PFUser currentUser]];
        }
        return;
    }

    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    NSDate *expirationDate = [[[FBSession activeSession] accessTokenData] expirationDate];
//    NSString *facebookUserId = [[[FBSession activeSession] accessTokenData] userID];
    NSString *facebookUserId = user.objectID;

    if (!accessToken || !facebookUserId) {
        NSLog(@"Login failure. FB Access Token or user ID does not exist");
        return;
    }

    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    // Unfortunately there are some issues with accessing the session provided from FBLoginView with the Parse SDK's (thread affinity)
    // Just work around this by setting the session to nil, since the relevant values will be discarded anyway when linking with Parse (permissions flag on FBAccessTokenData)
    // that we need to get back again with a refresh of the session
    if ([[FBSession activeSession] respondsToSelector:@selector(clearAffinitizedThread)]) {
        [[FBSession activeSession] performSelector:@selector(clearAffinitizedThread)];
    }

    [PFFacebookUtils logInWithFacebookId:facebookUserId
                             accessToken:accessToken
                          expirationDate:expirationDate
                                   block:^(PFUser *user, NSError *error) {

                                       if (!error) {
                                           [self.hud removeFromSuperview];
                                           if (self.delegate) {
                                               if ([self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
                                                   [self.delegate performSelector:@selector(logInViewControllerDidLogUserIn:) withObject:user];
                                               }
                                           }
                                       } else {
                                           [self cancelLogIn:error];
                                       }
                                   }];
}


#pragma mark - ()

- (void)cancelLogIn:(NSError *)error {

    if (error) {
        [self handleLogInError:error];
    }

    [self.hud removeFromSuperview];
    [[FBSession activeSession] closeAndClearTokenInformation];
    [PFUser logOut];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentLoginViewController:NO];
}

- (void)handleLogInError:(NSError *)error {
    if (error) {
        NSLog(@"Error: %@", [[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"]);
        NSString *title = NSLocalizedString(@"Login Error", @"Login error title in PAPLogInViewController");
        NSString *message = NSLocalizedString(@"Something went wrong. Please try again.", @"Login error message in PAPLogInViewController");

        if ([[[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:UserLoginCancelled"]) {
            return;
        }

        if (error.code == kPFErrorFacebookInvalidSession) {
            NSLog(@"Invalid session, logging out.");
            [[FBSession activeSession] closeAndClearTokenInformation];
            return;
        }

        if (error.code == kPFErrorConnectionFailed) {
            NSString *ok = NSLocalizedString(@"OK", @"OK");
            NSString *title = NSLocalizedString(@"Offline Error", @"Offline Error");
            NSString *message = NSLocalizedString(@"Something went wrong. Please try again.", @"Offline message");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:ok, nil];
            [alert show];

            return;
        }

        NSString *ok = NSLocalizedString(@"OK", @"OK");

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:ok, nil];
        [alertView show];
    }
}



@end
