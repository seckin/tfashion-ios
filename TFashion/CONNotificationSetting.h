//
//  CONNotificationSetting.h
//  TFashion
//
//  Created by Utku Sakil on 1/12/15.
//
//

#import <Parse/Parse.h>

@interface CONNotificationSetting : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property PFUser *user;
@property NSString *likes;
@property NSString *comments;
@property NSString *theNewFollowers;

@end
