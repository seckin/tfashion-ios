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
#import "CONTagDetailPopover.h"

@implementation PAPPhotoCell
@synthesize photoButton;
@synthesize imageOverlay;
@synthesize clothOverlays;


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
        [self.contentView addSubview:self.photoButton];

        // Adding an observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clothOverlayAdded:) name:@"clothOverlayAdded" object:nil];


        CONDEMOTag *tag = [CONDEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.6874, 0.53)],
                @"tagText" : @""}];

        [self setTag:tag];

        self.tagpopover = [[CONTagPopover  alloc] init];//[CONTagPopover initWithTag:self.tag];
        [self.tagpopover initWithTag:self.tag];
        [self.contentView addSubview:self.tagpopover];

//        [self.contentView bringSubviewToFront:self.imageView];
        [self.contentView bringSubviewToFront:self.tagpopover];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTagPopoverTapGesture:) ];
        tapGesture.numberOfTapsRequired = 2;
        [self.tagpopover addGestureRecognizer:tapGesture];
    }

    return self;
}

- (void)clothOverlayAdded:(NSNotification *)note {
    NSLog(@"clothoverlayadded notification triggered/received");
//     = [[CONImageOverlay alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width)];
//    self.clothOverlays
}

- (void)handleTagPopoverTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {

        [self.tagpopover removeFromSuperview];
        
        CONDEMOTag *tag = [CONDEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.574, 0.53)], @"tagText" : @"!"}];
        
        self.tagdetailpopover = [[CONTagDetailPopover alloc] init];
        [self.tagdetailpopover initWithTag:tag];
        [self.contentView addSubview:self.tagdetailpopover];
        
        
        NSLog(@"karla tap handler");
    }
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
    self.imageOverlay = [[CONImageOverlay alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width)];

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
