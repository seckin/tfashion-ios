//
//  TFSignUpViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/11/14.
//
//

#import "TFSignUpViewController.h"
#import "TFSignupAttempt.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"

@interface TFSignUpViewController ()

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *objectId;

@end

@implementation TFSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Customize sign up view
    self.signUpView.logo = nil;
    [self.signUpView.usernameField removeFromSuperview];
    [self.signUpView.passwordField removeFromSuperview];
    [self.signUpView.signUpButton setTitle:@"Send Verification Code to Sign Up" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"Send Verification Code to Sign Up" forState:UIControlStateHighlighted];
    NSArray *signUpButtonActions = [self.signUpView.signUpButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    for (int i = 0; i<signUpButtonActions.count; i++) {
        SEL oldAction = NSSelectorFromString(signUpButtonActions[i]);
        [self.signUpView.signUpButton removeTarget:self action:oldAction forControlEvents:UIControlEventTouchUpInside];
    }
    [self.signUpView.signUpButton addTarget:self action:@selector(showSMS:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create sign up attemp instance
    PFACL *acl = [PFACL ACL];
    [acl setPublicReadAccess:YES];
    [acl setPublicWriteAccess:YES];
    TFSignupAttempt *signupAttemp = [TFSignupAttempt object];
    signupAttemp.verificationCode = [self randomStringWithLength:6];
    signupAttemp.messageArrived = NO;
    signupAttemp.ACL = acl;
    [signupAttemp saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            _code = signupAttemp.verificationCode;
            _objectId = signupAttemp.objectId;
            
            _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [_codeLabel setText:_code];
            [_codeLabel setFont:[UIFont boldSystemFontOfSize:35]];
            [_codeLabel setTextColor:[UIColor colorWithRed:91.0f/255.0f green:107.0f/255.0f blue:118.0f/255.0f alpha:1.0f]];
            [self.signUpView addSubview:_codeLabel];
            [_codeLabel sizeToFit];
            _codeLabel.center = CGPointMake(self.signUpView.center.x, CGRectGetMinY(self.signUpView.signUpButton.frame)-60);
        }
    }];
    
}

#pragma mark - Actions

- (void)showSMS:(id)sender
{
    // If there is no network connection, we will not perform show sms event.
    if (_code.length == 0 || !(AppDelegate *)[[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"There is no network connection" message:@"Please check your connection and try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *message = _code;
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    NSArray *recipients = [NSArray arrayWithObject:@"12057200127"];
    [messageController setRecipients:recipients];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

#pragma mark - Private

- (NSString *)randomStringWithLength:(int)len
{
    NSString *alphabet  = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return s;
}

- (void)getResult
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = NSLocalizedString(@"Verifying", nil);
    self.hud.dimBackground = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"SignupAttempt"];
    [query whereKey:@"objectId" equalTo:_objectId];
    [query whereKey:@"verificationCode" equalTo:_code];
    [query whereKey:@"messageArrived" equalTo:[NSNumber numberWithBool:YES]];
    [self sendQuery:query];
}

- (void)sendQuery:(PFQuery *)query
{
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu objects.", (unsigned long)objects.count);
            if (objects.count == 0) {
                [self sendQuery:query];
            } else {
                TFSignupAttempt *signupAttempt = objects[0];
                NSLog(@"signup attempt %@", signupAttempt.objectId);
                [self authenticateUserWithPhoneNumber:signupAttempt.senderNumber];
            }
        } else {
            [self.hud hide:YES];
            
            [self showWarning];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)authenticateUserWithPhoneNumber:(NSString *)phoneNumber
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:phoneNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu user.", (unsigned long)objects.count);
            if (objects.count == 0) {
                [PFUser enableAutomaticUser];
                PFUser *user = [PFUser currentUser];
                user.username = phoneNumber;
                user.password = @"password";
                [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self.hud hide:YES];
                    if (!error) {
                        [PFUser becomeInBackground:user.sessionToken block:^(PFUser *user, NSError *error) {
                            if (error) {
                                // The token could not be validated.
                                NSLog(@"token could not be validated %@", [error userInfo]);
                            } else {
                                // The current user is now set to user.
                                [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                                UINavigationController *navController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] navController];
                                [navController dismissViewControllerAnimated:YES completion:nil];
                            }
                        }];
                    } else {
                        NSLog(@"sign up not successful %@", [error userInfo]);
                        [self showWarning];
                    }
                }];
            } else {
                PFUser *user = objects[0];
                NSLog(@"session token: %@", user.sessionToken);
                [PFUser logInWithUsernameInBackground:user.username password:@"password" block:^(PFUser *user, NSError *error) {
                    [self.hud hide:YES];
                    if (!error) {
                        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
                        UINavigationController *navController = [(AppDelegate*)[[UIApplication sharedApplication] delegate] navController];
                        [navController dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        NSLog(@"login not successful %@", [error userInfo]);
                        [self showWarning];
                    }
                }];
            }
        } else {
            NSLog(@"Become Error: %@ %@", error, [error userInfo]);
            [self.hud hide:YES];
            [self showWarning];
        }
        
    }];
}

#pragma mark - Message compose view controller delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
        {
            [self getResult];
        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Alert

- (void)showWarning
{
    UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Something went wrong. Please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [warningAlert show];
}

@end
