//
//  CONInviteFriendsViewController.h
//  TFashion
//
//  Created by Utku Sakil on 12/22/14.
//
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "THContactPickerView.h"
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface CONInviteFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, readonly) NSArray *selectedContacts;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, readonly) NSArray *filteredContacts;

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) didChangeSelectedItems;
- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
