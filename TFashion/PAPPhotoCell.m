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
@synthesize clothOverlays;
@synthesize popover1;
@synthesize popover2;
@synthesize popover3;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];

        self.imageView.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.userInteractionEnabled = YES;

        [self loadGestureRecognizers];

        [self.contentView addSubview:self.photoButton];
    }

    return self;
}

- (void)loadGestureRecognizers
{
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self.imageView addGestureRecognizer:doubleTapGesture];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];

//    for(int i = 0; i < [self.clothesDataArr count]; i++) {
//        NSDictionary *cloth_data = [self.clothesDataArr objectAtIndex:i];
//        if([PAPUtility isLocationInsideCloth:location.x withY:location.y clothData:cloth_data]) {
//            CONImageOverlay *tmpImageOverlay = [[CONImageOverlay alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width)];
//            tmpImageOverlay.clothDataArr = cloth_data;
//
//            POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
//            animation.fromValue = @(0.0);
//            animation.toValue = @(0.40);
//
//            [tmpImageOverlay pop_addAnimation:animation forKey:@"fadespring"];
//
//            [NSTimer scheduledTimerWithTimeInterval:0.2
//                                             target:self
//                                           selector:@selector(removeImageOverlay:)
//                                           userInfo:nil
//                                            repeats:NO];
//
//            [self.clothOverlays addObject:tmpImageOverlay];
//            [self addSubview:[self.clothOverlays objectAtIndex:([self.clothOverlays count] - 1)]];
//        }
//    }

    [self setNeedsDisplay];
}

- (void) removeImageOverlay:(NSTimer*)theTimer {
    for(int i = 0 ; i < [self.clothOverlays count]; i++) {
        [[self.clothOverlays objectAtIndex:i] removeFromSuperview];
    }
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
    self.photoButton.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
}

@end
