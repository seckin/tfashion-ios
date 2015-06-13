//
//  PAPPhotoCell.m
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <pop/POPAnimatableProperty.h>
#import <pop/POPBasicAnimation.h>
#import <pop/POPSpringAnimation.h>
#import "PAPPhotoCell.h"
#import "PAPUtility.h"
#import "CONImageOverlay.h"
#import "POPSpringAnimation.h"
#import "CONDemoTag.h"
#import "CONTagPopover.h"

@implementation PAPPhotoCell
@synthesize photoButton;
@synthesize imageOverlay;


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];

        self.imageView.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.photoButton.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
        self.photoButton.backgroundColor = [UIColor clearColor];
//        [self.photoButton addTarget:self action:@selector(photoButtonDoubleTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.photoButton addTarget:self action:@selector(photoButtonDoubleTap:) forControlEvents:UIControlEventTouchDownRepeat];
        NSLog(@"photoButton added as subview");
        [self.contentView addSubview:self.photoButton];

        CONDEMOTag *tag = [CONDEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.6874, 0.53)],
                @"tagText" : @"Karla"}];

        [self setTag:tag];

        self.tagpopover = [[CONTagPopover  alloc] init];//[CONTagPopover initWithTag:self.tag];
        [self.tagpopover initWithTag:self.tag];
        [self.contentView addSubview:self.tagpopover];

//        [self.contentView bringSubviewToFront:self.imageView];
        [self.contentView bringSubviewToFront:self.tagpopover];
    }

    return self;
}

- (void) removeImageOverlay:(NSTimer*)theTimer {
    [self.imageOverlay removeFromSuperview];
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
    self.photoButton.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
}

#pragma mark - Actions

- (void)photoButtonDoubleTap:(id)sender
{
    NSLog(@"burda92");
    self.imageOverlay = [[CONImageOverlay alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width)];


//        POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        animation.fromValue = @(0.0);
//        animation.toValue = @(1.0);
//        animation.duration = 2.0f;
//        [self.imageOverlay pop_addAnimation:animation forKey:@"fade"];

    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    animation.fromValue = @(0.0);
    animation.toValue = @(0.5);
    [self.imageOverlay pop_addAnimation:animation forKey:@"fadespring"];

    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(removeImageOverlay:)
                                   userInfo:nil
                                    repeats:NO];
    [self addSubview:self.imageOverlay];
    [self setNeedsDisplay];
}

@end
