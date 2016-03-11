//
//  PAPWelcomeViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/10/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#include <UIKit/UIKit.h>
#import "PAPLogInViewController.h"

@interface PAPWelcomeViewController : UIViewController <PAPLogInViewControllerDelegate>

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;

- (void)presentLoginViewController:(BOOL)animated;
- (void)presentBrowserController:(BOOL)animated;

@end
