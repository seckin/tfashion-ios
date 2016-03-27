//
//  PAPPhotoHeaderView.m
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoEmptySpaceView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPUtility.h"

@interface PAPPhotoEmptySpaceView ()
@property (nonatomic, strong) UIView *containerView;
@end

@implementation PAPPhotoEmptySpaceView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = YES;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, 10.0f)];

//        CALayer *midBorder = [CALayer layer];
//        midBorder.borderColor = [UIColor grayColor].CGColor;
//        midBorder.borderWidth = 1;
//        midBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.frame), 1);
//        [self.containerView.layer addSublayer:midBorder];
//
//        CALayer *bottomBorder = [CALayer layer];
//        bottomBorder.borderColor = [UIColor grayColor].CGColor;
//        bottomBorder.borderWidth = 1;
//        bottomBorder.frame = CGRectMake(0, 9, CGRectGetWidth(self.containerView.frame), 1);
//        [self.containerView.layer addSublayer:bottomBorder];

        [self addSubview:self.containerView];
        [self.containerView setBackgroundColor:[UIColor whiteColor]];//[UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:0.5]];
    }

    return self;
}

@end
