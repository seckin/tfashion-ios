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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "MBProgressHUD.h"
#import "Bugsnag.h"

@interface PAPLogInViewController() {
//    FBLoginView *_facebookLoginView;
    PFLogInView *_logInView;
    UILabel *appName;
    UILabel *appIntro;
}

@property (nonatomic, strong) MBProgressHUD *hud;



@end
//
//@interface FBSession (Private)
//
//- (void)clearAffinitizedThread;
//
//@end

@implementation PAPLogInViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchBackGround.png"]];

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
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    loginButton.center = self.view.center;
    CGRect frame = CGRectMake(36.0f, yPosition, 244.0f, 44.0f);
    loginButton.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    [self.view addSubview:loginButton];
    
    
    // Sign up button
//    _logInView = [[PFLogInView alloc] initWithFields:PFLogInFieldsSignUpButton];
//    _logInView.backgroundColor = [UIColor clearColor];
//    _logInView.frame = CGRectMake(20.0f, CGRectGetMaxY(_facebookLoginView.frame) + 10, 276.0f, 62.0f);
//    [self.view addSubview:_logInView];
//
//    NSArray *signUpButtonActions = [_logInView.signUpButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
//    for (int i = 0; i<signUpButtonActions.count; i++) {
//        SEL oldAction = NSSelectorFromString(signUpButtonActions[i]);
//        [_logInView.signUpButton removeTarget:self action:oldAction forControlEvents:UIControlEventTouchUpInside];
//    }
//    [_logInView.signUpButton addTarget:self action:@selector(showSignUpController:) forControlEvents:UIControlEventTouchUpInside];
//    [_logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
//    [_logInView.signUpButton setTitle:@"Sign Up With Text" forState:UIControlStateNormal];
//    [_logInView.signUpButton setFont:[UIFont boldSystemFontOfSize:16]];
//    _logInView.signUpButton.layer.cornerRadius = 10;
//    _logInView.signUpButton.layer.borderWidth = 3;
//    _logInView.signUpButton.layer.borderColor = [UIColor whiteColor].CGColor;


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

#pragma mark - ()


@end
