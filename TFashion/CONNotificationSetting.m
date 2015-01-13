//
//  CONNotificationSetting.m
//  TFashion
//
//  Created by Utku Sakil on 1/12/15.
//
//

#import "CONNotificationSetting.h"

@implementation CONNotificationSetting
@dynamic user;
@dynamic likes;
@dynamic comments;
@dynamic theNewFollowers;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"NotificationSetting";
}

@end
