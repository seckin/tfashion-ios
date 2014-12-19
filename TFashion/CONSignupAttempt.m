//
//  TFSignupAttemp.m
//  TFashion
//
//  Created by Utku Sakil on 12/11/14.
//
//

#import "CONSignupAttempt.h"
#import <Parse/PFObject+Subclass.h>

@implementation CONSignupAttempt
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
