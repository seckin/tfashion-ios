//
//  CONAccount.h
//  TFashion
//
//  Created by Utku Sakil on 12/31/14.
//
//

#import <Parse/Parse.h>

@interface CONSocialAccount : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property PFUser *ownerUser;

// All credentials
@property (copy, nonatomic) NSDictionary *info;

// Accounts are stored with a particular account type.
@property (strong, nonatomic) NSString *type;

// The id for the account.
@property (copy, nonatomic) NSString *userId;

// The username for the account.
@property (copy, nonatomic) NSString *username;

// The display name for the account.
@property (copy, nonatomic) NSString *displayName;

// This properties are only valid for OAuth1 credentials
@property (copy, nonatomic) NSString *oauth1Token;
@property (copy, nonatomic) NSString *oauth1Secret;


// This properties are only valid for OAuth2 credentials
@property (copy, nonatomic) NSString *oauth2Token;
@property (copy, nonatomic) NSString *refreshToken;
@property (copy, nonatomic) NSDate *tokenExpiryDate;
@property (nonatomic, strong) NSArray *scope;

// This property show the account is activated by user.
// User can disable connection of account after authentication.
@property (assign, nonatomic) BOOL isActive;

@end
