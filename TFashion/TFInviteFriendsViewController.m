//
//  TFInviteFriendsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 11/26/14.
//
//

#import "TFInviteFriendsViewController.h"
#import "TFContact.h"
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

NSString *const kDeniedTitle = @"Access to address book is denied";
NSString *const kDeniedMessage = @"Please enable access in Privacy Settings";
NSString *const kRestrictedMessage = @"Access to address book is restricted";
NSString *const kNotGrantedMessage = @"Access to address book is not granted";
NSString *const kLastModificationDate = @"LastModificationDate";

@interface TFInviteFriendsViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
{
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSMutableArray *contacts;

@end

@implementation TFInviteFriendsViewController

ABAddressBookRef addressBook;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Invite Friends";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(actionSend:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsTableView.allowsMultipleSelectionDuringEditing = YES;
    searchDisplayController.searchResultsTableView.editing = YES;
    
    self.tableView.tableHeaderView = searchBar;
    
    [self addressBookAuthorization];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionSend:(id)sender
{
    //TODO: send mail, sms
}

- (void)actionCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)updateSelectionButtons:(UITableView *)tableView forSelectedRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == searchDisplayController.searchResultsTableView){
        TFContact *person = [self.searchResults objectAtIndex:indexPath.row];
        NSUInteger indexOfPerson = [self.tableData indexOfObject:person];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfPerson inSection:indexPath.section] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    
    if (selectedRows.count != 0) {
        //TODO: Count
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)displayMessage:(NSString *)message withTitle:(NSString *)title
{
    [TSMessage showNotificationInViewController:self title:title subtitle:message type:TSMessageNotificationTypeError duration:2 canBeDismissedByUser:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [self.tableData count];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateSelectionButtons:tableView forSelectedRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateSelectionButtons:tableView forSelectedRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    TFContact *contact;
    if (tableView == searchDisplayController.searchResultsTableView) {
        contact = [self.searchResults objectAtIndex:indexPath.row];
        
        // secilen kisilerin search tablosunda da secili gelmesi icin
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        NSMutableIndexSet *selectedIndexSet = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *indexPath in selectedRows) {
            [selectedIndexSet addIndex:[indexPath row]];
        }
        NSArray *selectedPeople = [_tableData objectsAtIndexes:selectedIndexSet];
        
        if ([selectedPeople containsObject:contact]) {
            [searchDisplayController.searchResultsTableView selectRowAtIndexPath:indexPath
                                                                             animated:NO
                                                                       scrollPosition:UITableViewScrollPositionNone];
        }
    } else {
        contact = [self.tableData objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = ((contact.fullName != nil) ? contact.fullName : nil);
    
    return cell;
}

#pragma mark - Search display delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Table search

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"fullName contains[c] %@", searchText];
    self.searchResults = [self.tableData filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark - AddressBook

- (void)addressBookAuthorization
{
    self.contacts = [[NSMutableArray alloc] init];
    
    CFErrorRef error = NULL;
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized: {
            addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            
            // Register address book external change callback to get notification when app is active
            ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, (__bridge void *)(self));
            
            NSDate *lastModificationDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastModificationDate];
            if (lastModificationDate) {
                [self getPersonOutOfAddressBook:addressBook lastModificationDateCheck:YES];
            } else {
                [self getPersonOutOfAddressBook:addressBook lastModificationDateCheck:NO];
            }
            break;
        }
        case kABAuthorizationStatusDenied:{
            [self displayMessage:kDeniedMessage withTitle:kDeniedTitle];
            break;
        }
        case kABAuthorizationStatusNotDetermined:{
            addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted){
                        [self displayMessage:kNotGrantedMessage withTitle:nil];
                        return;
                    }
                    // Register address book external change callback to get notification when app is active
                    ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, (__bridge void *)(self));
                    
                    [self getPersonOutOfAddressBook:addressBook lastModificationDateCheck:NO];
                });
            });
            break;
        }
        case kABAuthorizationStatusRestricted:{
            [self displayMessage:kRestrictedMessage withTitle:nil];
            break;
        }
    }
}

void addressBookChanged(ABAddressBookRef reference,
                        CFDictionaryRef dictionary,
                        void *context)
{
    
    TFInviteFriendsViewController *viewController = (__bridge TFInviteFriendsViewController*)context;
    [viewController addressBookChanged];
}

- (void)addressBookChanged
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (error) {
        CFRelease(addressBook);
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
    
    [self getPersonOutOfAddressBook:addressBook lastModificationDateCheck:YES];
}

- (void)getPersonOutOfAddressBook:(ABAddressBookRef)addressBook lastModificationDateCheck:(BOOL)lastModificationDateCheck
{
    NSMutableArray *newContacts = [[NSMutableArray alloc] init];
    
    if (addressBook != nil)
    {
        NSArray *allContacts = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, nil, kABPersonSortByFirstName));
        NSMutableSet *linkedPersonsToSkip = [[NSMutableSet alloc] init];
        
        NSDate *lastModificationDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastModificationDate];
        
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            // skip if contact has already been merged
            if ([linkedPersonsToSkip containsObject:(__bridge id)(contactPerson)]) {
                continue;
            }
            
            TFContact *contact = [[TFContact alloc] init];
            contact.addressBookRecordId = [NSNumber numberWithInt:ABRecordGetRecordID(contactPerson)];
            contact.fromUser = [PFUser currentUser];
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", ((firstName != nil) ? firstName : @""), ((lastName != nil) ? lastName : @"")];
            
            contact.firstName = firstName;
            contact.lastName = lastName;
            contact.fullName = fullName;
            
            //phone
            ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSMutableArray *phonesMutable = [[NSMutableArray alloc] init];
            for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
            {
                
                NSString *num = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phones, j);
                // Format phone number
                NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
                NBPhoneNumber *phoneNumber = [phoneUtil parseWithPhoneCarrierRegion:num error:nil];
                num = [phoneUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
                [phonesMutable addObject:num];
            }
            contact.phoneNumbers = phonesMutable;
            
            //email
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSMutableArray *emailsMutable = [[NSMutableArray alloc] init];
            NSUInteger k = 0;
            for (k = 0; k < ABMultiValueGetCount(emails); k++)
            {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, k);
                [emailsMutable addObject:email];
            }
            contact.emails = emailsMutable;
            
            //linked accounts
            NSArray *linked = (__bridge NSArray *) ABPersonCopyArrayOfAllLinkedPeople(contactPerson);
            if (linked.count > 1) {
                [linkedPersonsToSkip addObjectsFromArray:linked];
            }
            
            if (contact.fullName.length > 0 && contact.addressBookRecordId != nil) {
                [self.contacts addObject:contact];
                
                if (lastModificationDateCheck == YES && lastModificationDate != nil) {
                    NSDate *modificationDate = (__bridge NSDate*) ABRecordCopyValue(contactPerson, kABPersonModificationDateProperty);
                    if ([modificationDate compare:lastModificationDate] != NSOrderedDescending) {
                        continue;
                    } else {
                        [newContacts addObject:contact];
                    }
                } else {
                    [newContacts addObject:contact];
                }
            }
        }
    }
    CFRelease(addressBook);
    
    [TFContact saveAllInBackground:newContacts block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:kLastModificationDate];
        }
    }];
    
    self.tableData = self.contacts;
    [self.tableView reloadData];
}

- (NSArray *)getSortedContactsOrderByModificationDate:(ABAddressBookRef)addressBook
{
    
    NSMutableArray * modificationDates = [[NSMutableArray alloc] init];
    if(addressBook != nil)
    {
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        if(nPeople > 0)
        {
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            for (int index = 0; index < nPeople; ++index)
            {
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, index);
                NSNumber *contactID = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
                NSDate *modificationDate = (__bridge NSDate*) ABRecordCopyValue(person, kABPersonModificationDateProperty);
                [modificationDates addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:contactID,modificationDate, nil] forKeys:[NSArray arrayWithObjects:@"contactID",@"modificationDate", nil]]];
            }
            if(allPeople)
                CFRelease(allPeople);
            allPeople = nil;
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:YES];
    [modificationDates sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return modificationDates;
}

- (NSDate *)getLastModificationDateOfAddressBook:(ABAddressBookRef)addressBook
{
    NSArray *sortedContacts = [self getSortedContactsOrderByModificationDate:addressBook];
    return [[sortedContacts valueForKey:@"modificationDate"] lastObject];
}

@end
