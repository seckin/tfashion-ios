//
//  TFSignupAttemp.h
//  TFashion
//
//  Created by Utku Sakil on 12/11/14.
//
//

#import <Parse/Parse.h>

@interface TFSignupAttemp : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *verificationCode;
@property BOOL messageArrived;
@property PFUser *user;

@end
