//
//  PAPWelcomeViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/10/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPLogInViewController.h"

@interface PAPWelcomeViewController : UIViewController <PAPLogInViewControllerDelegate>

- (void)presentLoginViewController:(BOOL)animated;

@end
