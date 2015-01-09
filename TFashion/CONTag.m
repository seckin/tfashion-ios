//
//  TFMention.m
//  TFashion
//
//  Created by Utku Sakil on 12/18/14.
//
//

#import "CONTag.h"

@implementation CONTag

@dynamic text;
@dynamic taggedObject;
@dynamic activity;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Tag";
}

@end
