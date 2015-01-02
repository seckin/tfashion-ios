//
//  TFSignUpViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/11/14.
//
//

#import "CONSignUpViewController.h"
#import "CONSignupAttempt.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

@interface CONSignUpViewController ()

@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIActivityIndicatorView *signUpActivityIndicatorView;

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *phoneNumber;

@end

@implementation CONSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Customize sign up view
    self.signUpView.logo = nil;
    self.signUpView.usernameField.hidden = YES;
    [self.signUpView.passwordField removeFromSuperview];
    [self.signUpView.emailField removeFromSuperview];
    [self setSignUpButtonToSendVerificationCodeButton];
    
    _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_codeLabel setText:[self randomStringWithLength:6]];
    [_codeLabel setFont:[UIFont boldSystemFontOfSize:35]];
    [_codeLabel setTextColor:[UIColor colorWithRed:91.0f/255.0f green:107.0f/255.0f blue:118.0f/255.0f alpha:1.0f]];
    [self.signUpView addSubview:_codeLabel];
    
    _signUpActivityIndicatorView = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.signUpView addSubview:_signUpActivityIndicatorView];
    
    // Create sign up attemp instance
    PFACL *acl = [PFACL ACL];
    [acl setPublicReadAccess:YES];
    [acl setPublicWriteAccess:YES];
    CONSignupAttempt *signupAttemp = [CONSignupAttempt object];
    signupAttemp.verificationCode = _codeLabel.text;
    signupAttemp.messageArrived = NO;
    signupAttemp.ACL = acl;
    [signupAttemp saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            _code = signupAttemp.verificationCode;
            _objectId = signupAttemp.objectId;
        }
    }];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_codeLabel sizeToFit];
    _codeLabel.center = self.signUpView.usernameField.center;
    
    _signUpActivityIndicatorView.center = CGPointMake(24, self.signUpView.signUpButton.center.y);
    
    [self.signUpView layoutIfNeeded];
}

#pragma mark - Actions

- (void)dismissVC:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

- (void)setSignUpButtonToSendVerificationCodeButton
{
    [self.signUpView.signUpButton setTitle:@"Send Verification Code to Sign Up" forState:UIControlStateNormal];
    NSArray *signUpButtonActions = [self.signUpView.signUpButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    for (int i = 0; i<signUpButtonActions.count; i++) {
        SEL oldAction = NSSelectorFromString(signUpButtonActions[i]);
        [self.signUpView.signUpButton removeTarget:self action:oldAction forControlEvents:UIControlEventTouchUpInside];
    }
    [self.signUpView.signUpButton addTarget:self action:@selector(showSMS:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setSendVerificationCodeButtonToSignUpButton
{
    [self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    NSArray *signUpButtonActions = [self.signUpView.signUpButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    for (int i = 0; i<signUpButtonActions.count; i++) {
        SEL oldAction = NSSelectorFromString(signUpButtonActions[i]);
        [self.signUpView.signUpButton removeTarget:self action:oldAction forControlEvents:UIControlEventTouchUpInside];
    }
    [self.signUpView.signUpButton addTarget:self action:@selector(authenticateUser:) forControlEvents:UIControlEventTouchUpInside];
    
}

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
    _phoneNumber = @"";
    PFQuery *query = [PFQuery queryWithClassName:@"SignupAttempt"];
    [query whereKey:@"objectId" equalTo:_objectId];
    [query whereKey:@"verificationCode" equalTo:_code];
    [query whereKey:@"messageArrived" equalTo:[NSNumber numberWithBool:YES]];
    [self sendQuery:query];
}

- (void)checkIfUserExist
{
    PFQuery *query = [PFUser query];
    [query whereKey:kPAPUserPhoneNumberKey equalTo:_phoneNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.hud hide:YES];
        if (!error) {
            NSLog(@"Successfully retrieved %lu user.", (unsigned long)objects.count);
            if (objects.count == 0) {
                self.signUpView.usernameField.hidden = NO;
            } else {
                PFUser *user = objects[0];
                [PFUser logInWithUsernameInBackground:user.username password:@"password" block:^(PFUser *user, NSError *error) {
                    [_signUpActivityIndicatorView stopAnimating];
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
            [self showWarning];
        }
    }];
    
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
                CONSignupAttempt *signupAttempt = objects[0];
                NSLog(@"signup attempt %@", signupAttempt.objectId);
                
                // Format phone number
                NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
                NBPhoneNumber *phoneNumber = [phoneUtil parseWithPhoneCarrierRegion:signupAttempt.senderNumber error:nil];
                _phoneNumber = [phoneUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
                
                [self checkIfUserExist];
            }
        } else {
            [self showWarning];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)authenticateUser:(id)sender
{
    NSString *username = self.signUpView.usernameField.text ?: @"";
    
    if (username.length == 0) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please enter a username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        
        return;
    }
    
    [PFUser enableAutomaticUser];
    PFUser *user = [PFUser currentUser];
    user.username = username;
    user.password = @"password";
    [user setObject:username forKey:kPAPUserDisplayNameKey];
    [user setObject:_phoneNumber forKey:kPAPUserPhoneNumberKey];
    [user setObject:[self getProfilePictureIsSmall:NO] forKey:kPAPUserProfilePicMediumKey];
    [user setObject:[self getProfilePictureIsSmall:YES] forKey:kPAPUserProfilePicSmallKey];
    [user setObject:[NSNumber numberWithBool:YES] forKey:kPAPUserDidUpdateUsernameKey];
    [_signUpActivityIndicatorView startAnimating];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [PFUser becomeInBackground:user.sessionToken block:^(PFUser *user, NSError *error) {
                [_signUpActivityIndicatorView stopAnimating];
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
            [_signUpActivityIndicatorView stopAnimating];
            [self showWarning];
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
            _codeLabel.hidden = YES;
            [self setSendVerificationCodeButtonToSignUpButton];
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.labelText = NSLocalizedString(@"Verifying", nil);
            self.hud.dimBackground = YES;
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
