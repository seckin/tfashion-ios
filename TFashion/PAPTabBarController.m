//
//  PAPTabBarController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPTabBarController.h"
#import "UIImage+ResizeAdditions.h"
#import "UIColor+CreateMethods.h"

@interface PAPTabBarController ()
@property (nonatomic,strong) UINavigationController *navController;
@end

@implementation PAPTabBarController
@synthesize navController;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabBar.tintColor = [UIColor whiteColor];
//    self.tabBar.tintColor = [UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    
    self.tabBar.barTintColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
//    self.tabBar.barTintColor = [UIColor colorWithHex:@"#7BC8A4" alpha:1.0f];

    [[UITabBar appearance] setSelectedImageTintColor:[UIColor darkGrayColor]];//[UIColor colorWithHex:@"#F16745" alpha:1.0f]];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];//[UIColor colorWithHex:@"#FFC65D" alpha:1.0f]];
    [[UITabBar appearance] setAlpha:1];

    self.navController = [[UINavigationController alloc] init];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    FAKIonIcons *cameraIcon = [FAKIonIcons iosCameraIconWithSize:27.0f];
    [cameraIcon addAttribute:NSForegroundColorAttributeName value:[UIColor
            grayColor]];

    UILabel *cameraText = [[UILabel alloc] init];
    [cameraText setText:@"Camera"];
    [cameraText setTextColor:[UIColor grayColor]];
    [cameraText setFont:[UIFont systemFontOfSize:10]];
    [cameraText setFrame:CGRectMake( 184.0f, 36.0f, 40.0f, 12.0f)];
    [cameraText setTextAlignment:NSTextAlignmentCenter];
//    [cameraText addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];

    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake( 180.0f, 2.0f, 51.0f, 35.0f);
    [cameraButton setImage:[cameraIcon imageWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
//    [cameraButton setBackgroundColor:[UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f]];
    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", @"") image:homeImage tag:0];
    [self.tabBar addSubview:cameraButton];
    [self.tabBar addSubview:cameraText];
}

- (BOOL)shouldPresentPhotoCaptureController
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }


    [self photoCaptureButtonAction:nil];
    return YES;
}

#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setForceQuadCrop:YES];
    
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - DBCameraViewControllerDelegate

- (void) dismissCamera:(id)cameraViewController{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    PAPEditPhotoViewController *viewController = [[PAPEditPhotoViewController alloc] initWithImage:image];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.presentedViewController.navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.presentedViewController presentViewController:nav animated:YES completion:nil];

}

@end
