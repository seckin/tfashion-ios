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

@property (nonatomic, strong) NSDictionary *likesCommentsNotificationSettingOptions;
@property (nonatomic, strong) NSDictionary *theNewFollowerNotificationSettingOptions;

@property (nonatomic, strong) NSArray *likesCommentsNotificationSettingTypes;
@property (nonatomic, strong) NSArray *theNewFollowersNotificationSettingTypes;

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
    
    self.likesCommentsNotificationSettingOptions = [NSDictionary dictionaryWithObjectsAndKeys:kOffTitle, kPAPNotificationSettingTypeOff, kFromPeopleIFollowTitle, kPAPNotificationSettingTypeFromPeopleIFollow, kFromEveryoneTitle, kPAPNotificationSettingTypeFromEveryone, nil];
    
    self.theNewFollowerNotificationSettingOptions = [NSDictionary dictionaryWithObjectsAndKeys:kOffTitle, kPAPNotificationSettingTypeOff, kFromEveryoneTitle, kPAPNotificationSettingTypeFromEveryone, nil];
    
    self.likesCommentsNotificationSettingTypes = [NSArray arrayWithObjects:kPAPNotificationSettingTypeOff, kPAPNotificationSettingTypeFromPeopleIFollow, kPAPNotificationSettingTypeFromEveryone, nil];
    
    self.theNewFollowersNotificationSettingTypes = [NSArray arrayWithObjects:kPAPNotificationSettingTypeOff, kPAPNotificationSettingTypeFromEveryone, nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaderTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return self.likesCommentsNotificationSettingOptions.count;
    } else if (section == 2) {
        return self.theNewFollowerNotificationSettingOptions.count;
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
    NSString *settingReadableName;
    
    if (indexPath.section == 0) {
        key = [self.likesCommentsNotificationSettingTypes objectAtIndex:row];
        settingReadableName = [self.likesCommentsNotificationSettingOptions objectForKey:key];
        if ([self.notificationSetting.likes isEqualToString:key]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == 1) {
        key = [self.likesCommentsNotificationSettingTypes objectAtIndex:row];
        settingReadableName = [self.likesCommentsNotificationSettingOptions objectForKey:key];
        if ([self.notificationSetting.comments isEqualToString:key]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == 2) {
        key = [self.theNewFollowersNotificationSettingTypes objectAtIndex:row];
        settingReadableName = [self.theNewFollowerNotificationSettingOptions objectForKey:key];
        if ([self.notificationSetting.theNewFollowers isEqualToString:key]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    cell.textLabel.text = settingReadableName;
    
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
    if (indexPath.section == 0) {
        self.notificationSetting.likes = [self.likesCommentsNotificationSettingTypes objectAtIndex:row];
    } else if (indexPath.section == 1) {
        self.notificationSetting.comments = [self.likesCommentsNotificationSettingTypes objectAtIndex:row];
    } else if (indexPath.section == 2) {
        self.notificationSetting.theNewFollowers = [self.theNewFollowersNotificationSettingTypes objectAtIndex:row];
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
