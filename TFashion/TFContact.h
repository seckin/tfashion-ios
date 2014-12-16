//
//  TFAddressBookPerson.h
//  TFashion
//
//  Created by Utku Sakil on 11/26/14.
//
//

#import <Parse/Parse.h>

@interface TFContact : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *firstName;
@property (retain) NSString *lastName;
@property (retain) NSString *fullName;
@property (retain) NSArray *emails;
@property (retain) NSArray *phoneNumbers;
@property (retain) NSNumber *addressBookRecordId;
@property PFUser *fromUser;

@end
