//
//  TFMention.h
//  TFashion
//
//  Created by Utku Sakil on 12/18/14.
//
//

#import <Parse/Parse.h>

@interface TFTag : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *text;
@property (retain) PFObject *taggedObject;
@property (retain) NSString *type;
@property (retain) PFObject *activity;

@end
