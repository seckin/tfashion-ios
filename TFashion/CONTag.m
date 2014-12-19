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
@dynamic type;
@dynamic activity;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Tag";
}

@end
