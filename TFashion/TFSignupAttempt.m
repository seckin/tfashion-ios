//
//  TFSignupAttemp.m
//  TFashion
//
//  Created by Utku Sakil on 12/11/14.
//
//

#import "TFSignupAttempt.h"
#import <Parse/PFObject+Subclass.h>

@implementation TFSignupAttempt
@dynamic verificationCode;
@dynamic senderNumber;
@dynamic messageArrived;
@dynamic user;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"SignupAttempt";
}

@end
