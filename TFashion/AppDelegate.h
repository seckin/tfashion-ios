//
//  AppDelegate.h
//  Anypic
//
//  Created by Héctor Ramos on 5/04/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPTabBarController.h"
#import "PAPWelcomeViewController.h"
#import "OneSignal.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) OneSignal *oneSignal;

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) PAPTabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;

@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;

- (void)presentLoginViewController;
- (void)presentLoginViewController:(BOOL)animated;
- (void)presentTabBarController;

- (void)logOut;

- (void)autoFollowUsers;

@end
