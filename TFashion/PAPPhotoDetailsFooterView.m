//
//  PAPPhotoDetailsFooterView.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/16/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoDetailsFooterView.h"
#import "PAPUtility.h"

@interface PAPPhotoDetailsFooterView ()
@property (nonatomic, strong) UIView *mainView;
@end

@implementation PAPPhotoDetailsFooterView

@synthesize commentField;
@synthesize mainView;
@synthesize hideDropShadow;


#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake( 20.0f, 0.0f, 280.0f, 51.0f)];
        mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]];
        [self addSubview:mainView];
        
        FAKIonIcons *addCommentIcon = [FAKIonIcons chatboxWorkingIconWithSize:19];
        [addCommentIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
        UIImageView *messageIcon = [[UIImageView alloc] initWithImage:[addCommentIcon imageWithSize:CGSizeMake(19.0f, 17.0f)]];
        messageIcon.frame = CGRectMake( 9.0f, 17.0f, 19.0f, 17.0f);
        [mainView addSubview:messageIcon];
        
        commentField = [[MPGTextField alloc] initWithFrame:CGRectMake( 40.0f, 10.0f, 227.0f, 31.0f)];
        commentField.font = [UIFont systemFontOfSize:14.0f];
        commentField.placeholder = @"Add a comment";
        commentField.returnKeyType = UIReturnKeySend;
        commentField.textColor = [UIColor darkGrayColor];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [commentField setValue:[UIColor colorWithRed:154.0f/255.0f green:146.0f/255.0f blue:138.0f/255.0f alpha:1.0f] forKeyPath:@"_placeholderLabel.textColor"]; // Are we allowed to modify private properties like this? -Héctor
        [mainView addSubview:commentField];
    }
    return self;
}


#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!hideDropShadow) {
        [PAPUtility drawSideAndBottomDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}


#pragma mark - PAPPhotoDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 69.0f);
}

@end
