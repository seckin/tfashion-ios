//
//  CONPushNotificationSettingsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/27/14.
//
//

#import "CONPushNotificationSettingsViewController.h"

@interface CONPushNotificationSettingsViewController ()

@property (nonatomic, strong) NSArray *likesArray;
@property (nonatomic, strong) NSArray *commentsArray;
@property (nonatomic, strong) NSArray *neWFollowersArray;

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
    
    self.likesArray = [NSArray arrayWithObjects:kOffTitle, kFromPeopleIFollowTitle, kFromEveryoneTitle, nil];
    self.commentsArray = [NSArray arrayWithObjects:kOffTitle, kFromPeopleIFollowTitle, kFromEveryoneTitle, nil];
    self.neWFollowersArray = [NSArray arrayWithObjects:kOffTitle, kFromEveryoneTitle, nil];
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
        return self.likesArray.count;
    } else if (section == 1) {
        return self.commentsArray.count;
    } else if (section == 2) {
        return self.neWFollowersArray.count;
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
        cell.textLabel.text = [self.likesArray objectAtIndex:indexPath.row];
        if (indexPath.row == 2) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [self.commentsArray objectAtIndex:indexPath.row];
        if (indexPath.row == 2) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == 2) {
        cell.textLabel.text = [self.neWFollowersArray objectAtIndex:indexPath.row];
        if (indexPath.row == 1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kLikesTitle;
    } else if (section == 1) {
        return kCommentsTitle;
    } else if (section == 2) {
        return kNewFollowersTitle;
    } else {
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    ToDoItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
//    tappedItem.completed = !tappedItem.completed;
//    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
