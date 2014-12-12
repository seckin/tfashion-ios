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

@interface TFSignUpViewController ()

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UIButton *smsButton;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *objectId;

@end

@implementation TFSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0f
                                                green:251.0f/255.0f
                                                 blue:1.0f
                                                alpha:1.0f];

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
            [self.view addSubview:_codeLabel];
            [_codeLabel sizeToFit];
            _codeLabel.center = CGPointMake(160, 240);
            
            _smsButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [_smsButton setTitle:@"Send Verification Code to Sign Up" forState:UIControlStateNormal];
            [_smsButton addTarget:self action:@selector(showSMS:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_smsButton];
            [_smsButton sizeToFit];
            _smsButton.center = CGPointMake(160, 280);
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (void)showSMS:(id)sender
{
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
    _codeLabel.hidden = YES;
    _smsButton.hidden = YES;
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
                [self.hud hide:YES];
                
                // Do something with the found objects
                for (PFObject *object in objects) {
                    NSLog(@"%@", object.objectId);
                }
            }
        } else {
            [self.hud hide:YES];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            _codeLabel.hidden = YES;
            _smsButton.hidden = YES;
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

@end
