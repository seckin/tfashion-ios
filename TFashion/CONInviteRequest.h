//
//  CONInviteRequest.h
//  TFashion
//
//  Created by Utku Sakil on 12/22/14.
//
//

#import <Parse/Parse.h>

@interface CONInviteRequest : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) PFObject *contact;
@property PFUser *fromUser;
@property BOOL invitationSent;

@end
