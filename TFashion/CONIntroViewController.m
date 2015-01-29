//
//  CONIntroViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/25/14.
//
//

#import "CONIntroViewController.h"

#define NUMBER_OF_PAGES 4

#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))

@interface CONIntroViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIImageView *wordmark;
@property (strong, nonatomic) UIImageView *unicorn;
@property (strong, nonatomic) UILabel *lastLabel;
@property (strong, nonatomic) UILabel *firstLabel;
@property (strong, nonatomic) UIButton *getStartedButton;
@property (strong, nonatomic) UITextField *usernameField;

@end

@implementation CONIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    
    self.scrollView.contentSize = CGSizeMake(NUMBER_OF_PAGES * CGRectGetWidth(self.view.frame),
                                             CGRectGetHeight(self.view.frame));
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    [self placeViews];
    [self configureAnimation];
    
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionGetStarted:(id)sender
{
    if (self.usernameField) {
        PFUser *currentParseUser = [PFUser currentUser];
        [currentParseUser setObject:[NSNumber numberWithBool:YES] forKey:kPAPUserDidUpdateUsernameKey];
        [currentParseUser setUsername:self.usernameField.text];
        [currentParseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kDidUserCompletedIntro];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self dismissViewControllerAnimated:YES completion:nil];
                if ([self.introViewControllerDelegate respondsToSelector:@selector(intoViewControllerDidDismiss:)]) {
                    [self.introViewControllerDelegate intoViewControllerDidDismiss:self];
                }
            } else {
                NSInteger errorCode = [error code];
                NSString *title = nil;
                NSString *subtitle = nil;
                if (errorCode == kPFErrorUsernameTaken) {
                    NSString *format = @"The username '%@' is taken. Please try choosing another username.";
                    title = @"Error";
                    subtitle = [NSString stringWithFormat:format, self.usernameField.text];
                } else {
                    title = @"Uh oh, something get wrong";
                    subtitle = @"Please check your connection and try again!";
                }
                [TSMessage showNotificationInViewController:self title:title subtitle:subtitle type:TSMessageNotificationTypeError duration:2 canBeDismissedByUser:YES];
            }
        }];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kDidUserCompletedIntro];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
        if ([self.introViewControllerDelegate respondsToSelector:@selector(intoViewControllerDidDismiss:)]) {
            [self.introViewControllerDelegate intoViewControllerDidDismiss:self];
        }
    }
    
    
}

- (void)textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    if (textField.text.length > 0) {
        self.getStartedButton.enabled = YES;
    } else {
        self.getStartedButton.enabled = NO;
    }
}

#pragma mark - Private

- (void)placeViews
{
    // put a unicorn in the middle of page two, hidden
    self.unicorn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Unicorn"]];
    self.unicorn.center = self.view.center;
    self.unicorn.frame = CGRectOffset(
                                      self.unicorn.frame,
                                      self.view.frame.size.width,
                                      -100
                                      );
    self.unicorn.alpha = 0.0f;
    [self.scrollView addSubview:self.unicorn];
    
    // put a logo on top of it
    self.wordmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IFTTT"]];
    self.wordmark.center = self.view.center;
    self.wordmark.frame = CGRectOffset(
                                       self.wordmark.frame,
                                       self.view.frame.size.width,
                                       -100
                                       );
    [self.scrollView addSubview:self.wordmark];
    
    self.firstLabel = [[UILabel alloc] init];
    self.firstLabel.textColor = [UIColor whiteColor];
    self.firstLabel.text = @"Introducing TFashion";
    [self.firstLabel sizeToFit];
    self.firstLabel.center = self.view.center;
    [self.scrollView addSubview:self.firstLabel];
    
    UILabel *secondPageText = [[UILabel alloc] init];
    secondPageText.textColor = [UIColor whiteColor];
    secondPageText.text = @"Brought to you by Conceive";
    [secondPageText sizeToFit];
    secondPageText.center = self.view.center;
    secondPageText.frame = CGRectOffset(secondPageText.frame, timeForPage(2), 180);
    [self.scrollView addSubview:secondPageText];
    
    UILabel *thirdPageText = [[UILabel alloc] init];
    thirdPageText.textColor = [UIColor whiteColor];
    thirdPageText.text = @"Simple keyframe animations";
    [thirdPageText sizeToFit];
    thirdPageText.center = self.view.center;
    thirdPageText.frame = CGRectOffset(thirdPageText.frame, timeForPage(3), -100);
    [self.scrollView addSubview:thirdPageText];
    
    UILabel *fourthPageText = [[UILabel alloc] init];
    fourthPageText.textColor = [UIColor whiteColor];
    fourthPageText.text = @"Optimized for scrolling intros";
    [fourthPageText sizeToFit];
    fourthPageText.center = self.view.center;
    fourthPageText.frame = CGRectOffset(fourthPageText.frame, timeForPage(4), -180);
    [self.scrollView addSubview:fourthPageText];
    
    self.lastLabel = fourthPageText;
    
    UIButton *fourthPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fourthPageButton setTitle:@"Get Started" forState:UIControlStateNormal];
    [fourthPageButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [fourthPageButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [fourthPageButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [fourthPageButton addTarget:self action:@selector(actionGetStarted:) forControlEvents:UIControlEventTouchUpInside];
    [fourthPageButton sizeToFit];
    fourthPageButton.center = self.view.center;
    fourthPageButton.frame = CGRectOffset(fourthPageButton.frame, timeForPage(4), 0);
    [self.scrollView addSubview:fourthPageButton];
    
    self.getStartedButton = fourthPageButton;
    
    PFUser *currentParseUser = [PFUser currentUser];
    if (![[currentParseUser valueForKey:kPAPUserDidUpdateUsernameKey] boolValue]) {
        self.usernameField = [[UITextField alloc] init];
        self.usernameField.delegate = self;
        self.usernameField.returnKeyType = UIReturnKeyDone;
        self.usernameField.enablesReturnKeyAutomatically = YES;
        [self.usernameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.usernameField.borderStyle = UITextBorderStyleRoundedRect;
        self.usernameField.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0f];
        self.usernameField.placeholder = @"Please enter a username";
        self.usernameField.textAlignment = NSTextAlignmentCenter;
        [self.usernameField sizeToFit];
        self.usernameField.center = self.view.center;
        self.usernameField.frame = CGRectOffset(self.usernameField.frame, timeForPage(4), -90);
        [self.scrollView addSubview:self.usernameField];
        
        self.getStartedButton.enabled = NO;
    }
    
}

- (void)configureAnimation
{
    CGFloat dy = 240;
    
    // apply a 3D zoom animation to the first label
    IFTTTTransform3DAnimation * labelTransform = [IFTTTTransform3DAnimation animationWithView:self.firstLabel];
    IFTTTTransform3D *tt1 = [IFTTTTransform3D transformWithM34:0.03f];
    IFTTTTransform3D *tt2 = [IFTTTTransform3D transformWithM34:0.3f];
    tt2.rotate = (IFTTTTransform3DRotate){ -(CGFloat)(M_PI), 1, 0, 0 };
    tt2.translate = (IFTTTTransform3DTranslate){ 0, 0, 50 };
    tt2.scale = (IFTTTTransform3DScale){ 1.f, 2.f, 1.f };
    [labelTransform addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(0)
                                                                andAlpha:1.0f]];
    [labelTransform addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1)
                                                          andTransform3D:tt1]];
    [labelTransform addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1.5)
                                                          andTransform3D:tt2]];
    [labelTransform addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1.5) + 1
                                                                andAlpha:0.0f]];
    [self.animator addAnimation:labelTransform];
    
    // let's animate the wordmark
    IFTTTFrameAnimation *wordmarkFrameAnimation = [IFTTTFrameAnimation animationWithView:self.wordmark];
    [self.animator addAnimation:wordmarkFrameAnimation];
    
    [wordmarkFrameAnimation addKeyFrames:@[
                                           [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:CGRectOffset(self.wordmark.frame, 200, 0)],
                                           [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:self.wordmark.frame],
                                           [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.wordmark.frame, self.view.frame.size.width, dy)],
                                           [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andFrame:CGRectOffset(self.wordmark.frame, 0, dy)],
                                           ]];
    
    // Rotate a full circle from page 2 to 3
    IFTTTAngleAnimation *wordmarkRotationAnimation = [IFTTTAngleAnimation animationWithView:self.wordmark];
    [self.animator addAnimation:wordmarkRotationAnimation];
    [wordmarkRotationAnimation addKeyFrames:@[
                                              [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAngle:0.0f],
                                              [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAngle:(CGFloat)(2 * M_PI)],
                                              ]];
    
    // now, we animate the unicorn
    IFTTTFrameAnimation *unicornFrameAnimation = [IFTTTFrameAnimation animationWithView:self.unicorn];
    [self.animator addAnimation:unicornFrameAnimation];
    
    CGFloat ds = 50;
    
    // move down and to the right, and shrink between pages 2 and 3
    [unicornFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:self.unicorn.frame]];
    [unicornFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3)
                                                                       andFrame:CGRectOffset(CGRectInset(self.unicorn.frame, ds, ds), timeForPage(2), dy)]];
    // fade the unicorn in on page 2 and out on page 4
    IFTTTAlphaAnimation *unicornAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.unicorn];
    [self.animator addAnimation:unicornAlphaAnimation];
    
    [unicornAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andAlpha:0.0f]];
    [unicornAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAlpha:1.0f]];
    [unicornAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAlpha:1.0f]];
    [unicornAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andAlpha:0.0f]];
    
    // Fade out the label by dragging on the last page
    IFTTTAlphaAnimation *labelAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.lastLabel];
    [labelAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andAlpha:1.0f]];
    [labelAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4.35f) andAlpha:0.0f]];
    [self.animator addAnimation:labelAlphaAnimation];
}

#pragma mark - IFTTTAnimatedScrollViewControllerDelegate

- (void)animatedScrollViewControllerDidScrollToEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController
{
    NSLog(@"Scrolled to end of scrollview!");
}

- (void)animatedScrollViewControllerDidEndDraggingAtEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController
{
    NSLog(@"Ended dragging at end of scrollview!");
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField) {
        if (self.getStartedButton.enabled) {
            [self actionGetStarted:self.getStartedButton];
            return NO;
        }
    }
    return YES;
}

@end
