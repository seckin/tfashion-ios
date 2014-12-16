//
//  TFSignupAttemp.h
//  TFashion
//
//  Created by Utku Sakil on 12/11/14.
//
//

#import <Parse/Parse.h>

@interface TFSignupAttempt : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *verificationCode;
@property (retain) NSString *senderNumber;
@property BOOL messageArrived;
@property PFUser *user;

@end
