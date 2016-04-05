//
//  PAPPhotoHeaderView.m
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoHeaderView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPUtility.h"
#import "TBActionSheet.h"

@interface PAPPhotoHeaderView () 
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) PAPProfileImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UIButton *reportButton;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) TBActionSheet *popup;
@end

@implementation PAPPhotoHeaderView
@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize reportButton;
@synthesize timeIntervalFormatter;
@synthesize photo;
@synthesize buttons;
@synthesize delegate;
@synthesize popup;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame buttons:(PAPPhotoHeaderButtons)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [PAPPhotoHeaderView validateButtons:otherButtons];
        buttons = otherButtons;

        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview:self.containerView];
        [self.containerView setBackgroundColor:[UIColor whiteColor]];

        self.avatarImageView = [[PAPProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 4.0f, 4.0f, 35.0f, 35.0f);
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.avatarImageView];
        
        if (self.buttons & PAPPhotoHeaderButtonsUser) {
            // This is the user's display name, on a button so that we can tap on it
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.userButton];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [[self.userButton titleLabel] setFont:[UIFont fontWithName:@"Gotham-Medium" size:15]];
            [self.userButton setTitleColor:[UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.userButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        }
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        // timestamp
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 24.0f, containerView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [containerView addSubview:self.timestampLabel];
        [self.timestampLabel setTextColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f]];
        [self.timestampLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:11.0f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];

        // report
        self.reportButton = [[UIButton alloc] initWithFrame:CGRectMake( 230.0f, 5.0f, 100.0f, 30.0f)];
        float ellipsisiconsize = 16.0f;
        FAKFontAwesome *plusIcon = [FAKFontAwesome ellipsisHIconWithSize:ellipsisiconsize];
        [plusIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        [self.reportButton setOpaque:YES];
        [self.reportButton setImage:[plusIcon imageWithSize:CGSizeMake(ellipsisiconsize, ellipsisiconsize)] forState:UIControlStateNormal];
        [self.reportButton setImage:[plusIcon imageWithSize:CGSizeMake(ellipsisiconsize, ellipsisiconsize)]
                           forState:UIControlStateSelected];
        [self.reportButton setTitle:@""
                           forState:UIControlStateNormal];
        [self.reportButton setTitle:@""
                           forState:UIControlStateSelected];
        [self.reportButton setTitleColor:[UIColor blackColor]
                                forState:UIControlStateNormal];
        [self.reportButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateSelected];
        [self.reportButton addTarget:self action:@selector(didTapReportButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];

        [containerView addSubview:self.reportButton];
//        [self.timestampLabel setTextColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f]];
//        [self.timestampLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:11.0f]];
//        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
    }

    return self;
}


#pragma mark - PAPPhotoHeaderView

- (void)setPhoto:(PFObject *)aPhoto {
    photo = aPhoto;

    // user's avatar
    PFUser *user = [self.photo objectForKey:kPAPPhotoUserKey];
    if ([PAPUtility userHasProfilePictures:user]) {
        PFFile *profilePictureSmall = [user objectForKey:kPAPUserProfilePicSmallKey];
        [self.avatarImageView setFile:profilePictureSmall];
    } else {
        [self.avatarImageView setImage:[PAPUtility defaultProfilePicture]];
    }

    [self.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.avatarImageView.layer.cornerRadius = 17.5;
    self.avatarImageView.layer.masksToBounds = YES;

    NSString *authorName = [user objectForKey:kPAPUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    CGFloat constrainWidth = containerView.bounds.size.width;

    if (self.buttons & PAPPhotoHeaderButtonsUser) {
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
    constrainWidth -= userButtonPoint.x;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);

    CGSize userButtonSize = [self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:self.userButton.titleLabel.font}
                                                    context:nil].size;
    
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.userButton setFrame:userButtonFrame];
    
    NSTimeInterval timeInterval = [[self.photo createdAt] timeIntervalSinceNow];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    [self.timestampLabel setText:timestamp];
    NSLog(@"framesize: %@", self.reportButton);

    [self setNeedsDisplay];
}

#pragma mark - ()

+ (void)validateButtons:(PAPPhotoHeaderButtons)buttons {
    if (buttons == PAPPhotoHeaderButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing PAPPhotoHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(photoHeaderView:didTapUserButton:user:)]) {
        [delegate photoHeaderView:self didTapUserButton:sender user:[self.photo objectForKey:kPAPPhotoUserKey]];
    }
}

- (void)didTapReportButtonAction:(UIButton *)sender {
    self.popup = [[TBActionSheet alloc] init];
//    self.popup = [[TBActionSheet alloc] initWithTitle:@"Options:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
//                            @"Report",
//                            nil];
    self.popup.delegate = self;
    self.popup.title = @"Select an option:";
    [self.popup addButtonWithTitle:@"Report"];
    self.popup.cancelButtonIndex = [self.popup addButtonWithTitle:@"Cancel"];
//    self.popup.cancel

    popup.tag = 1;
    UIViewController *vc = (UIViewController *)[self getViewController];
    [self.popup showInView:vc.view];
}

- (UIViewController *)getViewController
{
    id vc = [self nextResponder];
    while(![vc isKindOfClass:[UIViewController class]] && vc!=nil)
    {
        vc = [vc nextResponder];
    }

    return vc;
}

- (void)actionSheet:(TBActionSheet *)sheetpopup clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (sheetpopup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"button index 0 clicked");
                    [self saveReport];
                    break;
                case 1:
                    NSLog(@"button index 1 clicked - cancel button");
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)saveReport {
    PFObject *report = [PFObject objectWithClassName:kPAPReportClassKey];

    [report setObject:[self.photo objectForKey:kPAPPhotoUserKey] forKey:kPAPReportToUserKey];
    [report setObject:[PFUser currentUser] forKey:kPAPReportFromUserKey];
    [report setObject:self.photo forKey:kPAPReportPhotoKey];
    [report saveEventually];
    [TSMessage showNotificationWithTitle:@"Report sent" type:TSMessageNotificationTypeSuccess];
}
@end
