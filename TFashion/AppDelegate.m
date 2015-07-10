//
//  AppDelegate.m
//  Anypic
//
//  Created by Héctor Ramos on 5/04/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "AppDelegate.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "PAPHomeViewController.h"
#import "PAPLogInViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPAccountViewController.h"
#import "PAPWelcomeViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "CONSignUpViewController.h"
#import "CONSocialAccount.h"
#import "CONV2IntroViewController.h"
#import <Lookback/Lookback.h>
#import <Analytics.h>

#if ENABLE_PONYDEBUGGER
#import <PonyDebugger/PonyDebugger.h>
#endif

@interface AppDelegate () {
    BOOL firstLaunch;
}

@property (nonatomic, strong) PAPHomeViewController *homeViewController;
@property (nonatomic, strong) PAPActivityFeedViewController *activityViewController;
@property (nonatomic, strong) PAPActivityFeedViewController *activityViewController2;
@property (nonatomic, strong) PAPAccountViewController *accountViewController;
@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) CONV2IntroViewController *v2IntroViewController;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //MARK: Initialize window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // ****************************************************************************
    // Parse initialization
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"P5xFUqEkqLlPjLoLPfPlX6GfOFPEqjmsf3ftGWfO" clientKey:@"BoCGSthLOiP3tXFauR6MRnKz1icZUHgMEB1pP1so"];
    [PFFacebookUtils initializeFacebook];
    // ****************************************************************************
    
#if ENABLE_PONYDEBUGGER
    
    PDDebugger *debugger = [PDDebugger defaultInstance];
    
    // Enable Network debugging, and automatically track network traffic that comes through any classes that implement either NSURLConnectionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate or NSURLSessionDataDelegate methods.
    [debugger enableNetworkTrafficDebugging];
    [debugger forwardAllNetworkTraffic];
    
    // Enable Core Data debugging, and broadcast the main managed object context.
//    [debugger enableCoreDataDebugging];
//    [debugger addManagedObjectContext:self.managedObjectContext withName:@"PonyDebugger Test App MOC"];
    
    // Enable View Hierarchy debugging. This will swizzle UIView methods to monitor changes in the hierarchy
    // Choose a few UIView key paths to display as attributes of the dom nodes
    [debugger enableViewHierarchyDebugging];
    [debugger setDisplayedViewAttributeKeyPaths:@[@"frame", @"hidden", @"alpha", @"opaque", @"accessibilityLabel", @"text"]];
    
    // Connect to a specific host
    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
    // Or auto connect via bonjour discovery
    //[debugger autoConnect];
    // Or to a specific ponyd bonjour service
    //[debugger autoConnectToBonjourServiceNamed:@"MY PONY"];
    
    // Enable remote logging to the DevTools Console via PDLog()/PDLogObjects().
    [debugger enableRemoteLogging];
    
#endif
    
    //MARK: Analytics Integration
    [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:@"3XB78eGNDWWIsLpHmpUvuZsuq31UXIix"]];
    
    //MARK: Crashlytics
    [Fabric with:@[CrashlyticsKit]];
    
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //MARK: Lookback initialization
    [Lookback_Weak setupWithAppToken:@"9k36krkbC9ACyqne4"];
//    [Lookback_Weak lookback].enabled = YES;
    [Lookback_Weak lookback].shakeToRecord = YES;
    [Lookback_Weak lookback].userIdentifier = [[UIDevice currentDevice] name];

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // Set up our app's global UIAppearance
    [self setupAppearance];

    // Use Reachability to monitor connectivity
    [self monitorReachability];

    self.welcomeViewController = [[PAPWelcomeViewController alloc] init];
    self.v2IntroViewController = [[CONV2IntroViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;

    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];

    [self handlePush:launchOptions];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL wasHandled = false;

    if ([PFFacebookUtils session]) {
        wasHandled |= [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    } else {
        wasHandled |= [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }

    wasHandled |= [self handleActionURL:url];

    return wasHandled;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }

    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([self checkNotificationType:UIUserNotificationTypeBadge]) {
            application.applicationIconBadgeNumber = 1;
            application.applicationIconBadgeNumber = 0;
        }
        
    } else {
        application.applicationIconBadgeNumber = 1;
        application.applicationIconBadgeNumber = 0;
    }
    

    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (BOOL)checkNotificationType:(UIUserNotificationType)type
{
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    return (currentSettings.types & type);
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
}

#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewController:(BOOL)animated {
    [self.welcomeViewController presentLoginViewController:animated];
}

- (void)presentLoginViewController {
    [self presentLoginViewController:YES];
}

- (void)presentTabBarController {    
    self.tabBarController = [[PAPTabBarController alloc] init];
    self.homeViewController = [[PAPHomeViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController2 = [[PAPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.activityViewController = [[PAPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    self.accountViewController.user = [PFUser currentUser];
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];

    UINavigationController *activityFeedNavigationController2 = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *accountNavigationController = [[UINavigationController alloc] initWithRootViewController:self.accountViewController];

    FAKIonIcons *homeIcon = [FAKIonIcons homeIconWithSize:27.0f];
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"", @"") image:[homeIcon imageWithSize:CGSizeMake(27.0f, 27.0f)] tag:0];

    FAKIonIcons *activityIcon = [FAKIonIcons iosBellIconWithSize:27.0f];
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"", @"") image:[activityIcon imageWithSize:CGSizeMake(27.0f, 27.0f)] tag:0];
    UITabBarItem *activityFeedTabBarItem2 = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"", @"") image:[activityIcon imageWithSize:CGSizeMake(27.0f, 27.0f)] tag:0];

    FAKFontAwesome *accountIcon = [FAKFontAwesome userIconWithSize:22.0f];
    UITabBarItem *accountTabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[accountIcon imageWithSize:CGSizeMake(22.0f, 22.0f)] tag:0];
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [activityFeedNavigationController2 setTabBarItem:activityFeedTabBarItem2];
    [accountNavigationController setTabBarItem:accountTabBarItem];
    
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[ homeNavigationController, activityFeedNavigationController2, emptyNavigationController, accountNavigationController];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];

    // seckin: by updating these lines below according to anypic-ios8, I think I broke the push notifications for ios7 devices.
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
            UIUserNotificationTypeBadge |
            UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)logOut {
    //MARK: Track Log out event for Analytics
    [[SEGAnalytics sharedAnalytics] track:@"Logged Out"
                               properties:nil];
    
    // clear cache
    [[PAPCache sharedCache] clear];

    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    [FBSession setActiveSession:nil];

    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.homeViewController = nil;
    self.activityViewController = nil;
    self.accountViewController = nil;
}


#pragma mark - ()

// Set up appearance parameters to achieve Pera's custom look and feel
- (void)setupAppearance {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f]];

    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                NSForegroundColorAttributeName: [UIColor blackColor]
                                }];

    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil]
        setTitleColor:[UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:254.0f/255.0f alpha:1.0f]
        forState:UIControlStateNormal];

    [[UISearchBar appearance] setTintColor:[UIColor darkGrayColor]];
    [self.window setTintColor:[[UINavigationBar appearance] tintColor]];
}

- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];

    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [self.homeViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions {

    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
                
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
            return;
        }
        
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *commentObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadCommentObjectIdKey];
        if (commentObjectId && commentObjectId.length > 0) {
            PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            return [query getObjectInBackgroundWithId:commentObjectId block:^(PFObject *object, NSError *error) {
                if (!error) {
                    PFObject *photo = [object valueForKey:kPAPActivityPhotoKey];
                    [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photo.objectId]];
                }
            }];
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                    NSLog(@"Presenting account view controller with user: %@", user);
                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [self presentTabBarController];

    [self.navController dismissViewControllerAnimated:YES completion:nil];
    return YES;
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kPAPLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
                NSLog(@"WOOP: %@", photoObjectId);
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
                return YES;
            }
        }
    }

    return NO;
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto {
    for (PFObject *photo in self.homeViewController.objects) {
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:PAPHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            PAPPhotoDetailsViewController *detailViewController = [[PAPPhotoDetailsViewController alloc] initWithPhoto:object];
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

- (void)autoFollowUsers {
    firstLaunch = YES;
    [PFCloud callFunctionInBackground:@"autoFollowUsers" withParameters:nil block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error auto following users: %@", error);
        }
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
        [self.homeViewController loadObjects];
    }];
}

@end
