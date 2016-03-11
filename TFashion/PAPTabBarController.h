//
//  PAPTabBarController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#include <UIKit/UIKit.h>
#import "PAPEditPhotoViewController.h"
#import "DBCamera/DBCamera-umbrella.h"
//#import <DBCamera/DBCameraContainerViewController.h>
//#import <DBCamera/DBCameraViewController.h>

@class DBCameraGridView;
@class DBCameraViewController;

@protocol PAPTabBarControllerDelegate;

@interface PAPTabBarController : UITabBarController <DBCameraViewControllerDelegate>

- (BOOL)shouldPresentPhotoCaptureController;

@end

@protocol PAPTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;

@end