//
//  CONSettingsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/27/14.
//
//

#import "CONSettingsViewController.h"
#import "PAPFindFriendsViewController.h"
#import "CONShareSettingsViewController.h"
#import "CONPushNotificationSettingsViewController.h"
#import "CONNotificationSetting.h"
#import "AppDelegate.h"

@interface CONSettingsViewController ()

@property (nonatomic, strong) NSArray *preferencesArray;

@end

@implementation CONSettingsViewController

NSString *const kFindFriendsTitle = @"Find Friends";
NSString *const kShareSettingsTitle = @"Share Settings";
NSString *const kPushNotificationSettingsTitle = @"Push Notification Settings";
NSString *const kLogOutTitle = @"Log Out";
NSString *const kPreferencesTitle = @"PREFERENCES";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    self.preferencesArray = [NSArray arrayWithObjects:kPushNotificationSettingsTitle, nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.preferencesArray.count;
    } else if (section == 2) {
        return 1;
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
    
    if (indexPath.section == 0) {
        cell.textLabel.text = kFindFriendsTitle;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [self.preferencesArray objectAtIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        cell.textLabel.text = kLogOutTitle;
        cell.textLabel.textColor = self.view.tintColor;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return kPreferencesTitle;
    } else {
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PAPFindFriendsViewController *findFriendsVC = [[PAPFindFriendsViewController alloc] init];
        [self.navigationController pushViewController:findFriendsVC animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            CONShareSettingsViewController *shareSettingsVC = [[CONShareSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:shareSettingsVC animated:YES];
        } else if (indexPath.row == 1) {
            CONPushNotificationSettingsViewController *notificationSettingsVC = [[CONPushNotificationSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:notificationSettingsVC animated:YES];
        }
    } else if (indexPath.section == 2) {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
    }
}

@end
