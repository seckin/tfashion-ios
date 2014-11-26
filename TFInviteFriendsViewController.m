//
//  TFInviteFriendsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 11/26/14.
//
//

#import "TFInviteFriendsViewController.h"
#import "TFPerson.h"
#import <TSMessages/TSMessage.h>

NSString *const kDeniedTitle = @"Access to address book is denied";
NSString *const kDeniedMessage = @"Please enable access in Privacy Settings";
NSString *const kRestrictedMessage = @"Access to address book is restricted";
NSString *const kNotGrantedMessage = @"Access to address book is not granted";

@interface TFInviteFriendsViewController ()

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSMutableArray *people;

@end

@implementation TFInviteFriendsViewController

ABAddressBookRef addressBook;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(actionSend:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    
    self.searchDisplayController.searchResultsTableView.allowsMultipleSelectionDuringEditing = YES;
    self.searchDisplayController.searchResultsTableView.editing = YES;
    
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

- (void)updateSelectionButtons
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [self.tableData count];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateSelectionButtons];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateSelectionButtons];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    TFPerson *person;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        person = [self.searchResults objectAtIndex:indexPath.row];
        
        // secilen kisilerin search tablosunda da secili gelmesi icin
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        NSMutableIndexSet *selectedIndexSet = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *indexPath in selectedRows) {
            [selectedIndexSet addIndex:[indexPath row]];
        }
        NSArray *selectedPeople = [_tableData objectsAtIndexes:selectedIndexSet];
        
        if ([selectedPeople containsObject:person]) {
            [self.searchDisplayController.searchResultsTableView selectRowAtIndexPath:indexPath
                                                                             animated:NO
                                                                       scrollPosition:UITableViewScrollPositionNone];
        }
    } else {
        person = [self.tableData objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = ((person.fullName != nil) ? person.fullName : nil);
    
    return cell;
}

#pragma mark - Search display delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
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
    self.people = [[NSMutableArray alloc] init];
    
    CFErrorRef error = NULL;
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized: {
            addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            /* Do your work and once you are finished ... */
            [self getPersonOutOfAddressBook:addressBook];
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
                    [self getPersonOutOfAddressBook:addressBook];
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

- (void)getPersonOutOfAddressBook:(ABAddressBookRef)addressBook
{
    if (addressBook != nil)
    {
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            TFPerson *person = [[TFPerson alloc] init];
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", ((firstName != nil) ? firstName : @""), ((lastName != nil) ? lastName : @"")];
            
            person.firstName = firstName;
            person.lastName = lastName;
            person.fullName = fullName;
            
            //phone
            ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSMutableArray *phonesMutable = [[NSMutableArray alloc] init];
            for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
            {
                
                NSString *num = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phones, j);
                [phonesMutable addObject:num];
            }
            person.phoneNumbers = phonesMutable;
            
            //email
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSMutableArray *emailsMutable = [[NSMutableArray alloc] init];
            NSUInteger k = 0;
            for (k = 0; k < ABMultiValueGetCount(emails); k++)
            {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, k);
                [emailsMutable addObject:email];
            }
            person.emails = emailsMutable;
            
            if (person.fullName.length > 0) {
                [self.people addObject:person];
            }
        }
    }
    CFRelease(addressBook);
    
    self.tableData = self.people;
    [self.tableView reloadData];
}

@end
