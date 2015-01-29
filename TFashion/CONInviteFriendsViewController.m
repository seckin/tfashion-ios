//
//  CONInviteFriendsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/22/14.
//
//

#import "CONInviteFriendsViewController.h"
#import "CONContact.h"
#import "CONInviteRequest.h"

@interface CONInviteFriendsViewController () <THContactPickerDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSMutableArray *contacts;

@end

@implementation CONInviteFriendsViewController

static const CGFloat kPickerViewHeight = 100.0;
NSString *const kDeniedTitle = @"Access to address book is denied";
NSString *const kDeniedMessage = @"Please enable access in Privacy Settings";
NSString *const kRestrictedMessage = @"Access to address book is restricted";
NSString *const kNotGrantedMessage = @"Access to address book is not granted";
NSString *const kLastModificationDate = @"LastModificationDate";

NSString *THContactPickerContactCellReuseID = @"THContactPickerContactCell";
ABAddressBookRef addressBook;

@synthesize contactPickerView = _contactPickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Invite Friends";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(actionSend:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight];
    }
    
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPickerViewHeight)];
    self.contactPickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderLabelText:@"Who would you like to invite?"];
    [self.contactPickerView setPromptLabelText:@"To:"];
    //[self.contactPickerView setLimitToOne:YES];
    [self.view addSubview:self.contactPickerView];
    
    CALayer *layer = [self.contactPickerView layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Fill the rest of the view with the table view
    CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    
    [self addressBookAuthorization];
}

- (void)viewDidLayoutSubviews {
    [self adjustTableFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionSend:(id)sender
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = NSLocalizedString(@"Sending", nil);
    self.hud.dimBackground = YES;
    
    for (CONContact *contact in self.selectedContacts) {
        CONInviteRequest *inviteRequest = [CONInviteRequest object];
        inviteRequest.fromUser = [PFUser currentUser];
        inviteRequest.invitationSent = NO;
        
        PFQuery *query = [PFQuery queryWithClassName:@"Contact"];
        [query whereKey:@"fromUser" equalTo:contact.fromUser];
        if (contact.phoneNumbers.count > 0) {
            [query whereKey:@"phoneNumbers" containedIn:contact.phoneNumbers];
        } else {
            [query whereKey:@"emails" containedIn:contact.emails];
        }
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                inviteRequest.contact = object;
            } else {
                inviteRequest.contact = contact;
            }
            
            [inviteRequest saveEventually];
        }];
    }
    
    [self.hud hide:YES];
    [TSMessage showNotificationWithTitle:@"Invitations has been sent" type:TSMessageNotificationTypeSuccess];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public properties

- (NSArray *)selectedContacts{
    return [self.privateSelectedContacts copy];
}

- (NSArray *)filteredContacts {
    if (!_filteredContacts) {
        _filteredContacts = _tableData;
    }
    return _filteredContacts;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (NSInteger)selectedCount {
    return self.privateSelectedContacts.count;
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedContacts {
    if (!_privateSelectedContacts) {
        _privateSelectedContacts = [NSMutableArray array];
    }
    return _privateSelectedContacts;
}

#pragma mark - Private methods

- (void)adjustTableFrame {
    CGFloat yOffset = self.contactPickerView.frame.origin.y + self.contactPickerView.frame.size.height;
    
    CGRect tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset);
    self.tableView.frame = tableFrame;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top bottom:bottomInset];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self detailForRowAtIndexPath:indexPath];
    cell.detailTextLabel.textColor = [UIColor grayColor];
}

- (NSPredicate *)newFilteringPredicateWithText:(NSString *)text {
    return [NSPredicate predicateWithFormat:@"fullName contains[cd] %@", text];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.filteredContacts valueForKey:@"fullName"] objectAtIndex:indexPath.row];
}

- (NSString *)detailForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *emails = [[self.filteredContacts valueForKey:@"emails"] objectAtIndex:indexPath.row];
    if (emails.count > 0) {
        return [emails componentsJoinedByString:@", "];
    } else {
        NSArray *phoneNumbers = [[self.filteredContacts valueForKey:@"phoneNumbers"] objectAtIndex:indexPath.row];
        return [phoneNumbers componentsJoinedByString:@", "];
    }
    
}

- (void)didChangeSelectedItems {
    if (self.selectedContacts.count != 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)displayMessage:(NSString *)message withTitle:(NSString *)title
{
    [TSMessage showNotificationInViewController:self title:title subtitle:message type:TSMessageNotificationTypeError duration:2 canBeDismissedByUser:YES];
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THContactPickerContactCellReuseID];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THContactPickerContactCellReuseID];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id contact = [self.filteredContacts objectAtIndex:indexPath.row];
    NSString *contactTitle = [self titleForRowAtIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:contact]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.privateSelectedContacts removeObject:contact];
        [self.contactPickerView removeContact:contact];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.privateSelectedContacts addObject:contact];
        [self.contactPickerView addContact:contact withName:contactTitle];
    }
    
    self.filteredContacts = self.tableData;
    [self didChangeSelectedItems];
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.tableData;
    } else {
        NSPredicate *predicate = [self newFilteringPredicateWithText:textViewText];
        self.filteredContacts = [self.tableData filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    CGRect frame = self.tableView.frame;
    frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    self.tableView.frame = frame;
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.privateSelectedContacts removeObject:contact];
    
    NSInteger index = [self.tableData indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self didChangeSelectedItems];
}

- (BOOL)contactPickerTextFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0){
        NSString *contact = [[NSString alloc] initWithString:textField.text];
        [self.privateSelectedContacts addObject:contact];
        [self.contactPickerView addContact:contact withName:textField.text];
    }
    return YES;
}

#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
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
    
    CONInviteFriendsViewController *viewController = (__bridge CONInviteFriendsViewController *)context;
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
            
            CONContact *contact = [[CONContact alloc] init];
            contact.addressBookRecordId = [NSNumber numberWithInt:ABRecordGetRecordID(contactPerson)];
            
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
    
    if (newContacts.count > 0) {
        NSMutableArray *dictArray = [[NSMutableArray alloc] init];
        for (CONContact *newContact in newContacts) {
            NSDictionary *contactDict = [newContact dictionaryWithValuesForKeys:newContact.allKeys];
            [dictArray addObject:contactDict];
        }
        
        [self sendContactsInBackground:dictArray chunkSize:50 block:^(BOOL succeeded, NSError *error) {
            BOOL isUpdateError = NO;
            if (error) {
                NSInteger errorCode = [error code];
                isUpdateError = ((errorCode == kPFScriptError) ? YES : NO);
            }
            
            if (isUpdateError || !error) {
                // Set last modification date after saving all new contacts
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:kLastModificationDate];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
        } trigger:^(){}];
    }
    
    self.tableData = self.contacts;
    [self.tableView reloadData];
}

- (void)sendContactsInBackground:(NSArray *)array chunkSize:(int)chunkSize block:(PFBooleanResultBlock)block trigger:(void(^)())trigger
{
    
    NSRange range = NSMakeRange(0, array.count <= chunkSize ? array.count:chunkSize);
    NSArray *sendArray = [array subarrayWithRange:range];
    NSArray *nextArray = nil;
    if (range.length<array.count) nextArray = [array subarrayWithRange:NSMakeRange(range.length, array.count-range.length)];
    
    NSDictionary *params = @{@"contacts": sendArray};
    [PFCloud callFunctionInBackground:@"sendContacts" withParameters:params block:^(id object, NSError *error) {
        BOOL isNotUpdateError = NO;
        if (error) {
            NSInteger errorCode = [error code];
            isNotUpdateError = ((errorCode == kPFScriptError) ? NO : YES);
        }
        
        if(!isNotUpdateError && nextArray){
            trigger(true);
            [self sendContactsInBackground:nextArray chunkSize:chunkSize block:block trigger:trigger];
        }
        else
        {
            trigger(true);
            block(object,error);
        }
    }];
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
