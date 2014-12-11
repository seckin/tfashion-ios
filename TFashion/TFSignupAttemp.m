//
//  TFSignupAttemp.m
//  TFashion
//
//  Created by Utku Sakil on 12/11/14.
//
//

#import "TFSignupAttemp.h"
#import <Parse/PFObject+Subclass.h>

@implementation TFSignupAttemp
@dynamic verificationCode;
@dynamic messageArrived;
@dynamic user;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"SignupAttemp";
}

@end
