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

    [[self tabBar] setBarTintColor:[UIColor whiteColor]];
    self.tabBar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTabBar"]];
    
    self.navController = [[UINavigationController alloc] init];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    FAKIonIcons *cameraIcon = [FAKIonIcons ios7CameraIconWithSize:30.0f];
    [cameraIcon addAttribute:NSForegroundColorAttributeName value:[UIColor
                                                                 whiteColor]];
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake( 129.0f, 7.0f, 61.0f, 35.0f);
    [cameraButton setImage:[cameraIcon imageWithSize:CGSizeMake(30.0f, 30.0f)] forState:UIControlStateNormal];
    [cameraButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTabBar"]]];
    cameraButton.layer.cornerRadius = 5.0f;
    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:cameraButton];
}


//#pragma mark - UIImagePickerDelegate
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    [self dismissViewControllerAnimated:NO completion:nil];
//    
//    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
//     
//    PAPEditPhotoViewController *viewController = [[PAPEditPhotoViewController alloc] initWithImage:image];
//    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//    
//    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//    [self.navController pushViewController:viewController animated:NO];
//    
//    [self presentViewController:self.navController animated:YES completion:nil];
//}

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
//    PAPEditPhotoViewController *viewController = [[PAPEditPhotoViewController alloc] initWithImage:image];
//    self.navigationController.navigationBarHidden = NO;
//    [self.navigationController pushViewController:viewController animated:NO];
//    [cameraViewController restoreFullScreenMode];
//    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    PAPEditPhotoViewController *viewController = [[PAPEditPhotoViewController alloc] initWithImage:image];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.presentedViewController.navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//    [self.presentedViewController.navigationController pushViewController:viewController animated:NO];
    [self.presentedViewController presentViewController:nav animated:YES completion:nil];
    
//    [self presentViewController:self.presentedViewController.navigationController animated:YES completion:nil];

}

@end
