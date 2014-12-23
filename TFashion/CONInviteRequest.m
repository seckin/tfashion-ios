//
//  CONInviteRequest.m
//  TFashion
//
//  Created by Utku Sakil on 12/22/14.
//
//

#import "CONInviteRequest.h"

@implementation CONInviteRequest
@dynamic contact;
@dynamic fromUser;
@dynamic invitationSent;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"InviteRequest";
}

@end
