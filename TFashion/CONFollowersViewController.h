//
//  CONFollowersViewController.h
//  TFashion
//
//  Created by Utku Sakil on 1/29/15.
//
//

#import <ParseUI/ParseUI.h>

@interface CONFollowersViewController : PFQueryTableViewController

@property (nonatomic, strong) PFUser *user;

- (id)initWithUser:(PFUser *)aUser;

@end
