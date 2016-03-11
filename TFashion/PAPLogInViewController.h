//
//  PAPLogInViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#include <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

@protocol PAPLogInViewControllerDelegate;

@interface PAPLogInViewController : UIViewController <FBLoginViewDelegate, PFLogInViewControllerDelegate>

@property (nonatomic, assign) id<PAPLogInViewControllerDelegate> delegate;

@end

@protocol PAPLogInViewControllerDelegate <NSObject>

- (void)logInViewControllerDidLogUserIn:(PAPLogInViewController *)logInViewController;

@end
