//
//  TFAddressBookPerson.h
//  TFashion
//
//  Created by Utku Sakil on 11/26/14.
//
//

#import <Foundation/Foundation.h>

@interface TFPerson : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSArray *emails;
@property (nonatomic, strong) NSArray *phoneNumbers;

@end
