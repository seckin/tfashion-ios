//
//  PAPTabBarController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPTabBarController.h"

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
    
    self.tabBar.barTintColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];

    self.navController = [[UINavigationController alloc] init];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    FAKIonIcons *cameraIcon = [FAKIonIcons iosCameraIconWithSize:30.0f];
    [cameraIcon addAttribute:NSForegroundColorAttributeName value:[UIColor
            blackColor]];
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake( 134.0f, 7.0f, 51.0f, 35.0f);
    [cameraButton setImage:[cameraIcon imageWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
//    [cameraButton setBackgroundColor:[UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f]];
    cameraButton.layer.borderColor = [UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f].CGColor;
    cameraButton.layer.borderWidth = 2.0f;
    cameraButton.layer.cornerRadius = 5.0f;
    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:cameraButton];
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
