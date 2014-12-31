//
//  TFShareSettingsViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/2/14.
//
//

#import "CONShareSettingsViewController.h"
#import <SimpleAuth/SimpleAuth.h>
#import "CONSocialAccount.h"
#import "CONProviderDetailViewController.h"

@interface CONShareSettingsViewController ()

@property (nonatomic, strong) NSArray *socialAccountProviders;
@property (nonatomic, strong) NSArray *providerIcons;
@property (nonatomic, strong) NSMutableDictionary *socialAccounts;

@property (nonatomic, strong) NSArray *facebookPermissions;

@end

@implementation CONShareSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Share Settings";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.socialAccountProviders = [NSArray arrayWithObjects:kSocialAccountTypeFacebook, kSocialAccountTypeTwitter, kSocialAccountTypeInstagram, kSocialAccountTypeTumblr, nil];
    
    self.socialAccounts = [[NSMutableDictionary alloc] init];
    
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
        [icon setAttributes:@{ NSForegroundColorAttributeName: [UIColor grayColor] }];
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

- (void)showProviderDetail:(NSIndexPath *)indexPath
{
    CONProviderDetailViewController *detail = [[CONProviderDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    NSNumber *key = [NSNumber numberWithInteger:[indexPath row]];
    detail.socialAccount = [self.socialAccounts valueForKey:[key stringValue]];
    
    [self.navigationController pushViewController:detail animated:YES];
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
        cell.userInteractionEnabled = NO;
    }
    
    NSString *provider = [self.socialAccountProviders objectAtIndex:indexPath.row];
    cell.textLabel.text = [provider capitalizedString];
    
    FAKZocial *icon = [self.providerIcons objectAtIndex:indexPath.row];
    cell.imageView.image = [icon imageWithSize:CGSizeMake(25.0f, 25.0f)];
    
    PFUser *user = [PFUser currentUser];
    NSString *providerIdKey = [NSString stringWithFormat:@"%@Id", provider];
    NSString *providerId = [user valueForKey:providerIdKey];
    
    PFQuery *query = [PFQuery queryWithClassName:@"SocialAccount"];
    [query whereKey:@"ownerUser" equalTo:user];
    [query whereKey:@"type" equalTo:provider];
    [query whereKey:@"providerId" equalTo:providerId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        cell.userInteractionEnabled = YES;
        if (objects.count == 1) {
            CONSocialAccount *socialAccount = objects[0];
            NSNumber *key = [NSNumber numberWithInteger:[indexPath row]];
            [self.socialAccounts setObject:socialAccount forKey:[key stringValue]];
            if (socialAccount.isActive) {
                [icon setAttributes:@{ NSForegroundColorAttributeName: self.view.tintColor }];
                cell.imageView.image = [icon imageWithSize:CGSizeMake(25.0f, 25.0f)];
                cell.detailTextLabel.text = socialAccount.providerDisplayName;
            }
        }
    }];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:
            [self actionAuthorizeFacebookWithIndexPath:indexPath];
            break;
        case 1:
            [self actionAuthorizeTwitterWithIndexPath:indexPath];
            break;
        case 2:
            [self actionAuthorizeInstagramWithIndexPath:indexPath];
            break;
        case 3:
            [self actionAuthorizeTumblrWithIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

#pragma mark - Authentication

- (void)actionAuthorizeFacebookWithIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [PFUser currentUser];
    NSNumber *key = [NSNumber numberWithInteger:[indexPath row]];
    CONSocialAccount *socialAccount = [self.socialAccounts valueForKey:[key stringValue]];
    if ([PAPUtility userHasValidFacebookData:user] && socialAccount.isActive) {
        [self showProviderDetail:indexPath];
    } else {
        self.facebookPermissions = @[ @"user_about_me", @"email", @"public_profile", @"user_friends" ];
        NSDictionary *options = @{ @"permissions" : self.facebookPermissions };
        [SimpleAuth authorize:@"facebook-web" options:options completion:^(id responseObject, NSError *error) {
            NSLog(@"\nError: %@", error);
            if (responseObject) {
                [self setUserFacebookAccountWithResponse:responseObject andIndexPath:indexPath];
            }
        }];
    }
}

- (void)actionAuthorizeTwitterWithIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [PFUser currentUser];
    NSNumber *key = [NSNumber numberWithInteger:[indexPath row]];
    CONSocialAccount *socialAccount = [self.socialAccounts valueForKey:[key stringValue]];
    if ([PAPUtility userHasValidTwitterData:user] && socialAccount.isActive) {
        [self showProviderDetail:indexPath];
    } else {
        [SimpleAuth authorize:@"twitter-web" completion:^(id responseObject, NSError *error) {
            NSLog(@"\nError: %@", error);
            if (responseObject) {
                [self setUserTwitterAccountWithResponse:responseObject andIndexPath:indexPath];
            }
        }];
    }
}

- (void)actionAuthorizeInstagramWithIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [PFUser currentUser];
    NSNumber *key = [NSNumber numberWithInteger:[indexPath row]];
    CONSocialAccount *socialAccount = [self.socialAccounts valueForKey:[key stringValue]];
    if ([PAPUtility userHasValidInstagramData:user] && socialAccount.isActive) {
        [self showProviderDetail:indexPath];
    } else {
        [SimpleAuth authorize:@"instagram" completion:^(id responseObject, NSError *error) {
            NSLog(@"\nError: %@", error);
            if (responseObject) {
                [self setUserInstagramAccountWithResponse:responseObject andIndexPath:indexPath];
            }
        }];
    }
}

- (void)actionAuthorizeTumblrWithIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [PFUser currentUser];
    NSNumber *key = [NSNumber numberWithInteger:[indexPath row]];
    CONSocialAccount *socialAccount = [self.socialAccounts valueForKey:[key stringValue]];
    if ([PAPUtility userHasValidTumblrData:user] && socialAccount.isActive) {
        [self showProviderDetail:indexPath];
    } else {
        [SimpleAuth authorize:@"tumblr" completion:^(id responseObject, NSError *error) {
            NSLog(@"\nError: %@", error);
            if (responseObject) {
                [self setUserTumblrAccountWithResponse:responseObject andIndexPath:indexPath];
            }
        }];
    }
}

#pragma mark - Response

- (void)setUserFacebookAccountWithResponse:(id)response andIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [PFUser currentUser];
    
    CONSocialAccount *socialAccount = [CONSocialAccount object];
    socialAccount.isActive = YES;
    socialAccount.ownerUser = user;
    socialAccount.info = response;
    socialAccount.type = kSocialAccountTypeFacebook;
    socialAccount.providerId = [response valueForKey:@"uid"];
    id info = [response valueForKey:@"info"];
    socialAccount.providerUsername = [info valueForKey:@"email"];
    socialAccount.providerDisplayName = [info valueForKey:@"name"];
    id credentials = [response valueForKey:@"credentials"];
    socialAccount.oauth2Token = [credentials valueForKey:@"token"];
    socialAccount.tokenExpiryDate = [credentials valueForKey:@"expires_at"];
    socialAccount.scope = self.facebookPermissions;
    
    return [socialAccount saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [user setValue:socialAccount.providerId forKey:kPAPUserFacebookIDKey];
            [user setValue:socialAccount.providerUsername forKey:kPAPUserEmailKey];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }
    }];
}

- (void)setUserTwitterAccountWithResponse:(id)response andIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [PFUser currentUser];
    
    CONSocialAccount *socialAccount = [CONSocialAccount object];
    socialAccount.isActive = YES;
    socialAccount.ownerUser = user;
    socialAccount.info = response;
    socialAccount.type = kSocialAccountTypeTwitter;
    socialAccount.providerId = [[response valueForKey:@"uid"] stringValue];
    id info = [response valueForKey:@"info"];
    socialAccount.providerUsername = [info valueForKey:@"nickname"];
    socialAccount.providerDisplayName = [info valueForKey:@"name"];
    id credentials = [response valueForKey:@"credentials"];
    socialAccount.oauth1Token = [credentials valueForKey:@"token"];
    socialAccount.oauth1Secret = [credentials valueForKey:@"secret"];
    
    return [socialAccount saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [user setValue:socialAccount.providerId forKey:kPAPUserTwitterIDKey];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }
    }];
}

- (void)setUserInstagramAccountWithResponse:(id)response andIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [PFUser currentUser];
    
    CONSocialAccount *socialAccount = [CONSocialAccount object];
    socialAccount.isActive = YES;
    socialAccount.ownerUser = user;
    socialAccount.info = response;
    socialAccount.type = kSocialAccountTypeInstagram;
    socialAccount.providerId = [response valueForKey:@"uid"];
    id userInfo = [response valueForKey:@"user_info"];
    socialAccount.providerUsername = [userInfo valueForKey:@"username"];
    socialAccount.providerDisplayName = [userInfo valueForKey:@"name"];
    id credentials = [response valueForKey:@"credentials"];
    socialAccount.oauth2Token = [credentials valueForKey:@"token"];

    return [socialAccount saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [user setValue:socialAccount.providerId forKey:kPAPUserInstagramIDKey];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }
    }];
    
}

- (void)setUserTumblrAccountWithResponse:(id)response andIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [PFUser currentUser];
    
    CONSocialAccount *socialAccount = [CONSocialAccount object];
    socialAccount.isActive = YES;
    socialAccount.ownerUser = user;
    socialAccount.info = response;
    socialAccount.type = kSocialAccountTypeTumblr;
    socialAccount.providerId = [response valueForKey:@"uid"];
    id info = [response valueForKey:@"info"];
    socialAccount.providerUsername = [info valueForKey:@"nickname"];
    socialAccount.providerDisplayName = [info valueForKey:@"name"];
    id credentials = [response valueForKey:@"credentials"];
    socialAccount.oauth1Token = [credentials valueForKey:@"token"];
    socialAccount.oauth1Secret = [credentials valueForKey:@"secret"];
    
    return [socialAccount saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [user setValue:socialAccount.providerId forKey:kPAPUserTumblrIDKey];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }
    }];
}

@end
