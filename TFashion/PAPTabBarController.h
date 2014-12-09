//
//  PAPTabBarController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPEditPhotoViewController.h"
#import <DBCamera/DBCameraContainerViewController.h>
#import <DBCamera/DBCameraViewController.h>

@protocol PAPTabBarControllerDelegate;

@interface PAPTabBarController : UITabBarController <DBCameraViewControllerDelegate>

- (BOOL)shouldPresentPhotoCaptureController;

@end

@protocol PAPTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;

@end