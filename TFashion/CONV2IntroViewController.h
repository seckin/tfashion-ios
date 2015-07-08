//
//  CONV2IntroViewController.h
//  TFashion
//
//  Created by Seckin Can Sahin on 6/28/15.
//
//

#import <UIKit/UIKit.h>

#include "PAPLogInViewController.h"

@interface CONV2IntroViewController : UIViewController <PAPLogInViewControllerDelegate>

- (void)presentLoginViewController:(BOOL)animated;

@end