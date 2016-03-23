//
//  UIViewController+CONForceFollowViewController.h
//  Standout
//
//  Created by Seckin Can Sahin on 3/23/16.
//
//

#import <UIKit/UIKit.h>

@interface CONForceFollowViewController: UIViewController

@property (nonatomic, strong) UIImage *profile;
@property (nonatomic, strong) UIScrollView *scrollView;
-(void)addUser:(int)index;
@end
