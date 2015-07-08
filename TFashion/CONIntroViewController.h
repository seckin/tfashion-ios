//
//  CONIntroViewController.h
//  TFashion
//
//  Created by Utku Sakil on 12/25/14.
//
//

#import "IFTTTJazzHands.h"

@protocol CONIntroViewControllerDelegate;

@interface CONIntroViewController : IFTTTAnimatedScrollViewController <IFTTTAnimatedScrollViewControllerDelegate>

@property (nonatomic, weak) id <CONIntroViewControllerDelegate> introViewControllerDelegate;

@end

@protocol CONIntroViewControllerDelegate <NSObject>

@optional

/**
 *  The user has clicked get started button and set his/her username successfully.
 *
 *  @param introViewController the scroll view controller that's been scrolled
 */
- (void)intoViewControllerDidDismiss:(CONIntroViewController *)introViewController;
- (IBAction)signUpButtonHandler:(id)sender;

@end
