//
//  PAPLogInViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#include <UIKit/UIKit.h>
#import "FBSDKCoreKit.h"
#import "FBSDKLoginKit.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@protocol PAPLogInViewControllerDelegate;

//@interface PAPLogInViewController : UIViewController <FBLoginViewDelegate, PFLogInViewControllerDelegate>
@interface PAPLogInViewController : UIViewController <PFLogInViewControllerDelegate, TTTAttributedLabelDelegate, UIWebViewDelegate>

@property (nonatomic, assign) id<PAPLogInViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end

@protocol PAPLogInViewControllerDelegate <NSObject>

- (void)logInViewControllerDidLogUserIn:(PAPLogInViewController *)logInViewController;

@end
