//
//  TFMention.m
//  TFashion
//
//  Created by Utku Sakil on 12/18/14.
//
//

#import "TFTag.h"

@implementation TFTag

@dynamic name;
@dynamic linkedObjectId;
@dynamic type;
@dynamic activityId;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Tag";
}

@end
