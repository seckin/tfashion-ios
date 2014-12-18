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

@property (retain) NSString *name;
@property (retain) NSString *linkedObjectId;
@property (retain) NSString *type;

@end
