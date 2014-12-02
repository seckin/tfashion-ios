//
//  TFShareSettingsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/2/14.
//
//

#import "TFShareSettingsViewController.h"

@interface TFShareSettingsViewController ()

@property (nonatomic, strong) NSArray *socialAccountProviders;
@property (nonatomic, strong) NSArray *providerIcons;

@end

@implementation TFShareSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Share Settings";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.socialAccountProviders = [NSArray arrayWithObjects:@"Facebook", @"Twitter", @"Instagram", @"Pinterest", @"Tumblr", nil];
    [self initializeProviderIcons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)initializeProviderIcons
{
    FAKZocial *facebookIcon = [FAKZocial facebookIconWithSize:20.0f];
    FAKZocial *twitterIcon = [FAKZocial twitterIconWithSize:20.0f];
    FAKZocial *instagramIcon = [FAKZocial instagramIconWithSize:20.0f];
    FAKZocial *pinterestIcon = [FAKZocial pinterestIconWithSize:20.0f];
    FAKZocial *tumblrIcon = [FAKZocial tumblrIconWithSize:20.0f];
    
    self.providerIcons = [NSArray arrayWithObjects:facebookIcon,twitterIcon,instagramIcon,pinterestIcon,tumblrIcon, nil];
    
    for (FAKZocial *icon in self.providerIcons) {
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.socialAccountProviders count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = [self.socialAccountProviders objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor grayColor];
    
    FAKZocial *icon = [self.providerIcons objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTabBar"]];
        [icon removeAttribute:NSForegroundColorAttributeName];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTabBar"]]];
    }
    
    cell.imageView.image = [icon imageWithSize:CGSizeMake(25.0f, 25.0f)];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
