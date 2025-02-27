//
//  TFMention.h
//  TFashion
//
//  Created by Utku Sakil on 12/18/14.
//
//

#import <Parse/Parse.h>

@interface CONTag : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *text;
@property (retain) PFObject *taggedObject;
@property (retain) PFObject *activity;

@end
