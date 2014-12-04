//
//  TFShareSettingsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/2/14.
//
//

#import "TFShareSettingsViewController.h"
#import <SocialAccounts/SocialAccounts.h>
#import <SimpleAuth/SimpleAuth.h>

@interface TFShareSettingsViewController ()

@property (nonatomic, strong) SOAccountStore *store;
@property (nonatomic, strong) NSArray *socialAccountProviders;
@property (nonatomic, strong) NSArray *providerIcons;

@property (nonatomic, strong) FAKZocial *facebookIcon;
@property (nonatomic, strong) FAKZocial *instagramIcon;
@property (nonatomic, strong) FAKZocial *pinterestIcon;
@property (nonatomic, strong) FAKZocial *tumblrIcon;

@end

@implementation TFShareSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Share Settings";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.socialAccountProviders = [NSArray arrayWithObjects:@"Facebook", @"Instagram", @"Pinterest", @"Tumblr", nil];
    
    [self initializeProviderIcons];
    
    [self configureAuthorizationProviders];
    
    self.store = [[SOAccountStore alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)initializeProviderIcons
{
    self.facebookIcon = [FAKZocial facebookIconWithSize:20.0f];
    self.instagramIcon = [FAKZocial instagramIconWithSize:20.0f];
    self.pinterestIcon = [FAKZocial pinterestIconWithSize:20.0f];
    self.tumblrIcon = [FAKZocial tumblrIconWithSize:20.0f];
    
    self.providerIcons = [NSArray arrayWithObjects:self.facebookIcon,self.instagramIcon,self.pinterestIcon,self.tumblrIcon, nil];
    
    for (FAKZocial *icon in self.providerIcons) {
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]];
    }
}

- (void)configureAuthorizationProviders
{
    SimpleAuth.configuration[@"instagram"] = @{
                                               @"client_id" : @"7335834df76b4db2afdcdcf147177e3e",
                                               SimpleAuthRedirectURIKey : @"ig7335834df76b4db2afdcdcf147177e3e://authorize"
                                               };
    
    SimpleAuth.configuration[@"pinterest"] = @{
                                               @"client_id" : @"1441756"
                                               };
    
    SimpleAuth.configuration[@"tumblr"] = @{
                                            @"consumer_key" : @"pNuKZqpbfqB5jXYsUH9Pi1lCHMRNb3mNrzVF4aH3AJlq28grfF",
                                            @"consumer_secret" : @"yYTVJPJw2aor6bkYOtuIekIVUgRQKSNucmbhd1znMtg6tcUDNU",
                                            };
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:
            break;
        case 1:
            [self actionAuthorizeInstagram];
            break;
        case 2:
            [self actionAuthorizePinterest];
            break;
        case 3:
            [self actionAuthorizeTumblr];
            break;
            
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)actionAuthorizeInstagram
{
    [SimpleAuth authorize:@"instagram" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError: %@", responseObject, error);
        
        if (responseObject) {
            SOAccountStore *store = [[SOAccountStore alloc] init];
            
            SOAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:SOAccountTypeIdentifierInstagram];
            
            SOAccount *account = [[SOAccount alloc] initWithAccountType:accountType];
            
            account.username = @"john";
            //        SOAccountCredential* credential = [[SOAccountCredential alloc] initWithOAuth2Token:@"2342341.b6fw422.b8f5ffs9sjqljq7a70e788884b67c" refreshToken:nil expiryDate:nil];
            //        credential.scope = @"relationships";
            //        account.credential = credential;
            //
            //        [store saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
            //            NSLog(@"Saved Account");
            //            NSLog(@"%@", [account description]);
            //        }];
            
            //        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isAuthenticated"];
            //        [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)actionAuthorizePinterest
{
    [SimpleAuth authorize:@"pinterest" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError: %@", responseObject, error);
    }];
}

- (void)actionAuthorizeTumblr
{
    [SimpleAuth authorize:@"tumblr" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError: %@", responseObject, error);
    }];
}

@end
