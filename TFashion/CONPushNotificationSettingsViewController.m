//
//  CONPushNotificationSettingsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/27/14.
//
//

#import "CONPushNotificationSettingsViewController.h"
#import "AppDelegate.h"

@interface CONPushNotificationSettingsViewController ()

@property (nonatomic, strong) NSArray *sectionHeaderTitles;

@property (nonatomic, strong) NSDictionary *likesCommentsDictionary;
@property (nonatomic, strong) NSDictionary *theNewFollowersDictionary;

@property (nonatomic, strong) NSArray *likesCommentsArray;
@property (nonatomic, strong) NSArray *theNewFollowersArray;

@end

@implementation CONPushNotificationSettingsViewController

NSString *const kLikesTitle = @"LIKES";
NSString *const kCommentsTitle = @"COMMENTS";
NSString *const kNewFollowersTitle = @"NEW FOLLOWERS";

NSString *const kOffTitle = @"Off";
NSString *const kFromPeopleIFollowTitle = @"From People I Follow";
NSString *const kFromEveryoneTitle = @"From Everyone";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Notifications";
    
    PFQuery *query = [PFQuery queryWithClassName:@"NotificationSetting"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"There is no network connection" message:@"Please check your connection and try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self setArraysAndDictionaries];
            if (objects.count == 1) {
                self.notificationSetting = objects[0];
            } else {
                CONNotificationSetting *notificationSetting = [CONNotificationSetting object];
                notificationSetting.likes = kPAPNotificationSettingTypeFromEveryone;
                notificationSetting.comments = kPAPNotificationSettingTypeFromEveryone;
                notificationSetting.theNewFollowers = kPAPNotificationSettingTypeFromEveryone;
                notificationSetting.user = [PFUser currentUser];
                self.notificationSetting = notificationSetting;
            }
            [self.tableView reloadData];
        } else {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Something went wrong. Please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)setArraysAndDictionaries
{
    self.sectionHeaderTitles = [NSArray arrayWithObjects:kLikesTitle, kCommentsTitle, kNewFollowersTitle, nil];
    
    self.likesCommentsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:kOffTitle, kPAPNotificationSettingTypeOff, kFromPeopleIFollowTitle, kPAPNotificationSettingTypeFromPeopleIFollow, kFromEveryoneTitle, kPAPNotificationSettingTypeFromEveryone, nil];
    
    self.theNewFollowersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:kOffTitle, kPAPNotificationSettingTypeOff, kFromEveryoneTitle, kPAPNotificationSettingTypeFromEveryone, nil];
    
    self.likesCommentsArray = [NSArray arrayWithObjects:kPAPNotificationSettingTypeOff, kPAPNotificationSettingTypeFromPeopleIFollow, kPAPNotificationSettingTypeFromEveryone, nil];
    
    self.theNewFollowersArray = [NSArray arrayWithObjects:kPAPNotificationSettingTypeOff, kPAPNotificationSettingTypeFromEveryone, nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaderTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return self.likesCommentsDictionary.count;
    } else if (section == 2) {
        return self.theNewFollowersDictionary.count;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    long row = [indexPath row];
    NSString *key;
    NSString *object;
    
    if (indexPath.section == 0) {
        key = [self.likesCommentsArray objectAtIndex:row];
        object = [self.likesCommentsDictionary objectForKey:key];
        if ([self.notificationSetting.likes isEqualToString:key]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == 1) {
        key = [self.likesCommentsArray objectAtIndex:row];
        object = [self.likesCommentsDictionary objectForKey:key];
        if ([self.notificationSetting.comments isEqualToString:key]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == 2) {
        key = [self.theNewFollowersArray objectAtIndex:row];
        object = [self.theNewFollowersDictionary objectForKey:key];
        if ([self.notificationSetting.theNewFollowers isEqualToString:key]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    cell.textLabel.text = object;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionHeaderTitles objectAtIndex:section];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    long row = [indexPath row];
    NSString *key;
    if (indexPath.section == 0) {
        key = [self.likesCommentsArray objectAtIndex:row];
        self.notificationSetting.likes = key;
    } else if (indexPath.section == 1) {
        key = [self.likesCommentsArray objectAtIndex:row];
        self.notificationSetting.comments = key;
    } else if (indexPath.section == 2) {
        key = [self.theNewFollowersArray objectAtIndex:row];
        self.notificationSetting.theNewFollowers = key;
    }
    
    [tableView reloadData];
    
    [self.notificationSetting saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Something went wrong. Please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            
            if (indexPath.section == 0) {
                self.notificationSetting.likes = nil;
            } else if (indexPath.section == 1) {
                self.notificationSetting.comments = nil;
            } else if (indexPath.section == 2) {
                self.notificationSetting.theNewFollowers = nil;
            }
        }
    }];
}

@end
