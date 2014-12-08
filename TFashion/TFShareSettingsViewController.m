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

@property (nonatomic, strong) NSArray *socialAccountProviders;
@property (nonatomic, strong) NSArray *providerIcons;

@end

@implementation TFShareSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Share Settings";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.socialAccountProviders = [NSArray arrayWithObjects:@"Facebook", @"Twitter", @"Instagram", @"Tumblr", nil];
    
    [self initializeProviderIcons];
    
    [self configureAuthorizationProviders];
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
    FAKZocial *tumblrIcon = [FAKZocial tumblrIconWithSize:20.0f];
    
    self.providerIcons = [NSArray arrayWithObjects:facebookIcon,twitterIcon,instagramIcon,tumblrIcon, nil];
    
    for (FAKZocial *icon in self.providerIcons) {
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]];
    }
}

- (void)configureAuthorizationProviders
{
    SimpleAuth.configuration[@"facebook-web"] = @{
                                                  @"app_id" : @"192275100793250"
                                                  };
    
    SimpleAuth.configuration[@"twitter-web"] = @{
                                                 @"consumer_key" : @"FBKTVDw0LZBu0SqvxfehdddPM",
                                                 @"consumer_secret" : @"FXMwptY5tSHP2S8gi1IlSqIoSLQdl2wuWwAoEDKZJUBKSJyZiN"
                                                 };
    
    SimpleAuth.configuration[@"instagram"] = @{
                                               @"client_id" : @"7335834df76b4db2afdcdcf147177e3e",
                                               SimpleAuthRedirectURIKey : @"ig7335834df76b4db2afdcdcf147177e3e://authorize"
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
            [self actionAuthorizeFacebook];
            break;
        case 1:
            [self actionAuthorizeTwitter];
            break;
        case 2:
            [self actionAuthorizeInstagram];
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

#pragma mark - Authentication

- (void)actionAuthorizeFacebook
{
    [SimpleAuth authorize:@"facebook-web" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError: %@", responseObject, error);
        if (responseObject) {
            [self setUserFacebookAccountWithResponse:responseObject];
        }
    }];
}

- (void)actionAuthorizeTwitter
{
    [SimpleAuth authorize:@"twitter-web" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError: %@", responseObject, error);
        if (responseObject) {
            [self setUserTwitterAccountWithResponse:responseObject];
        }
    }];
}

- (void)actionAuthorizeInstagram
{
    [SimpleAuth authorize:@"instagram" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError: %@", responseObject, error);
        
        if (responseObject) {
            [self setUserInstagramAccountWithResponse:responseObject];
        }
    }];
}

- (void)actionAuthorizeTumblr
{
    [SimpleAuth authorize:@"tumblr" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError: %@", responseObject, error);
        
        if (responseObject) {
            [self setUserTumblrAccountWithResponse:responseObject];
        }
    }];
}

#pragma mark - Response

- (void)setUserFacebookAccountWithResponse:(id)response
{
    SOAccountStore *store = [[SOAccountStore alloc] init];
    
    SOAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:SOAccountTypeIdentifierFacebook];
    
    SOAccount *account = [[SOAccount alloc] initWithAccountType:accountType];
    
    account.userId = [response valueForKey:@"uid"];
    id info = [response valueForKey:@"info"];
    account.username = [info valueForKey:@"email"];
    id credentials = [response valueForKey:@"credentials"];
    SOAccountCredential *credential = [[SOAccountCredential alloc] initWithOAuth2Token:[credentials valueForKey:@"token"] refreshToken:nil expiryDate:[credentials valueForKey:@"expires_at"]];
    credential.scope = @"";
    account.credential = credential;
    
    [store saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Saved Account");
        [self.tableView reloadData];
    }];
    
    for (SOAccount* account in store.accounts) {
        NSLog(@"loaded account %@", account.credential.oauthToken);
    }
}

- (void)setUserTwitterAccountWithResponse:(id)response
{
    SOAccountStore *store = [[SOAccountStore alloc] init];
    
    SOAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:SOAccountTypeIdentifierTwitter];
    
    SOAccount *account = [[SOAccount alloc] initWithAccountType:accountType];
    
    account.userId = [response valueForKey:@"uid"];
    id info = [response valueForKey:@"info"];
    account.username = [info valueForKey:@"nickname"];
    id credentials = [response valueForKey:@"credentials"];
    SOAccountCredential *credential = [[SOAccountCredential alloc] initWithOAuthToken:[credentials valueForKey:@"token"] tokenSecret:[credentials valueForKey:@"secret"]];
    account.credential = credential;
    
    [store saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Saved Account");
        [self.tableView reloadData];
    }];
    
    for (SOAccount* account in store.accounts) {
        NSLog(@"loaded account %@", account.credential.oauthToken);
    }
}

- (void)setUserInstagramAccountWithResponse:(id)response
{
    SOAccountStore *store = [[SOAccountStore alloc] init];
    
    SOAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:SOAccountTypeIdentifierInstagram];
    
    SOAccount *account = [[SOAccount alloc] initWithAccountType:accountType];
    
    account.userId = [response valueForKey:@"uid"];
    id userInfo = [response valueForKey:@"user_info"];
    account.username = [userInfo valueForKey:@"username"];
    id credentials = [response valueForKey:@"credentials"];
    SOAccountCredential *credential = [[SOAccountCredential alloc] initWithOAuth2Token:[credentials valueForKey:@"token"] refreshToken:nil expiryDate:nil];
    credential.scope = @"";
    account.credential = credential;
    
    [store saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Saved Account");
        [self.tableView reloadData];
    }];
    
    for (SOAccount* account in store.accounts) {
        NSLog(@"loaded account %@", account.credential.oauthToken);
    }
}

- (void)setUserTumblrAccountWithResponse:(id)response
{
    SOAccountStore *store = [[SOAccountStore alloc] init];
    
    SOAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:SOAccountTypeIdentifierTumblr];
    
    SOAccount *account = [[SOAccount alloc] initWithAccountType:accountType];
    
    account.userId = [response valueForKey:@"uid"];
    id info = [response valueForKey:@"info"];
    account.username = [info valueForKey:@"nickname"];
    id credentials = [response valueForKey:@"credentials"];
    SOAccountCredential *credential = [[SOAccountCredential alloc] initWithOAuthToken:[credentials valueForKey:@"token"] tokenSecret:[credentials valueForKey:@"secret"]];
    account.credential = credential;
    
    [store saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Saved Account");
        [self.tableView reloadData];
    }];
    
    for (SOAccount* account in store.accounts) {
        NSLog(@"loaded account %@", account.credential.oauthToken);
    }
}

@end
