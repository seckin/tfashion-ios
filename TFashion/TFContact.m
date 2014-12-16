//
//  TFAddressBookPerson.m
//  TFashion
//
//  Created by Utku Sakil on 11/26/14.
//
//

#import "TFContact.h"

@implementation TFContact
@dynamic firstName;
@dynamic lastName;
@dynamic fullName;
@dynamic emails;
@dynamic phoneNumbers;
@dynamic addressBookRecordId;
@dynamic fromUser;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Contact";
}

@end
