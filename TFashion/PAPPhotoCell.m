//
//  PAPPhotoCell.m
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

//#import <pop/POPAnimatableProperty.h>
//#import <pop/POPBasicAnimation.h>
#import "PAPPhotoCell.h"
#import "PAPUtility.h"
#import "CONImageOverlay.h"
#import "pop.h"
#import "CONDemoTag.h"
#import "CONTagPopover.h"
#import "PINCache.h"

@implementation PAPPhotoCell
@synthesize photo;
@synthesize photoButton;
@synthesize imageOverlay;
@synthesize clothOverlays;

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
    __block NSArray *clothes;
    [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothesForPhoto:self.photo] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
        clothes = (NSArray *)tmpobj;
        NSLog(@"handling double tap");
        NSLog(@"[clothes count]:");
        NSLog(@"%lu", (unsigned long)[clothes count]);

        for(int i = 0; i < [clothes count]; i++) {
            NSLog(@"handling %d", i);
            PFObject *cloth = [clothes objectAtIndex:i];
            __block NSArray *cloth_pieces;
            [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothPiecesForCloth:cloth] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
                cloth_pieces = tmpobj;
                if (cloth_pieces && cloth_pieces.count > 0 && [PAPUtility isLocationInsideCloth:location.x withY:location.y clothPieces:cloth_pieces]) {
                    NSLog(@"location inside cloth!");
                    CONImageOverlay *tmpImageOverlay = [[CONImageOverlay alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width)];
                    tmpImageOverlay.cloth_pieces = cloth_pieces;

                    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
                    animation.fromValue = @(0.0);
                    animation.toValue = @(0.40);

                    [tmpImageOverlay pop_addAnimation:animation forKey:@"fadespring"];

                    [NSTimer scheduledTimerWithTimeInterval:0.2
                                                     target:self
                                                   selector:@selector(removeImageOverlay:)
                                                   userInfo:nil
                                                    repeats:NO];

                    [self.clothOverlays addObject:tmpImageOverlay];
                    [self addSubview:[self.clothOverlays objectAtIndex:([self.clothOverlays count] - 1)]];
                }
            }];
        }
    }];


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
