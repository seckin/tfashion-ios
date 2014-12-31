//
//  CONAccount.m
//  TFashion
//
//  Created by Utku Sakil on 12/31/14.
//
//

#import "CONSocialAccount.h"

@implementation CONSocialAccount
@dynamic ownerUser, info, type, providerId, providerUsername, providerDisplayName, oauth1Secret, oauth1Token, oauth2Token, refreshToken, tokenExpiryDate, scope, isActive;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"SocialAccount";
}

@end
