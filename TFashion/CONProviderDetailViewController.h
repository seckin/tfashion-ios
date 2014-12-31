//
//  CONProviderDetailViewController.h
//  TFashion
//
//  Created by Utku Sakil on 12/31/14.
//
//

#import <UIKit/UIKit.h>
#import "CONShareSettingsViewController.h"
#import "CONSocialAccount.h"

@interface CONProviderDetailViewController : UITableViewController

@property CONShareSettingsViewController *master;

@property CONSocialAccount *socialAccount;
@property NSIndexPath *providerIndexPath;

@end
