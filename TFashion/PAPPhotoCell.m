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
@synthesize tagPopovers;

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

//        self.clothOverlays = [[NSMutableArray alloc] init];
        self.tagPopovers = [[NSMutableArray alloc] init];

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
        NSLog(@"location.x: %f location.y: %f", location.x, location.y);
        __block NSArray *clothes;
        [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothesForPhoto:self.photo] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
            clothes = (NSArray *) tmpobj;
            NSLog(@"handling double tap");
            NSLog(@"[clothes count]:");
            NSLog(@"%lu", (unsigned long) [clothes count]);

            for (int i = 0; i < [clothes count]; i++) {
                NSLog(@"handling %d", i);
                PFObject *cloth = [clothes objectAtIndex:i];
                __block NSArray *cloth_pieces;
                [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothPiecesForCloth:cloth] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cloth_pieces = tmpobj;
                        if (cloth_pieces && cloth_pieces.count > 0 && [PAPUtility isLocationInsideCloth:location.x withY:location.y clothPieces:cloth_pieces]) {
                            NSLog(@"location inside cloth!");
                            self.imageOverlay = [[CONImageOverlay alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width)];
                            self.imageOverlay.cloth_pieces = cloth_pieces;

                            POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
                            animation.fromValue = @(0.0);
                            animation.toValue = @(0.40);

                            [self.imageOverlay pop_addAnimation:animation forKey:@"fadespring"];

                            [NSTimer scheduledTimerWithTimeInterval:0.2
                                                             target:self
                                                           selector:@selector(removeImageOverlay:)
                                                           userInfo:nil
                                                            repeats:NO];

                            [self.clothOverlays addObject:self.imageOverlay];
                            [self addSubview:self.imageOverlay];
                            [self.contentView setNeedsDisplay];
                            NSLog(@"location inside cloth done!");
                        }
                    });
                }];
            }
        }];
}

- (void) removeImageOverlay:(NSTimer*)theTimer {
    NSLog(@"removeImageOverlay called");
    [self.imageOverlay removeFromSuperview];
    self.imageOverlay = nil;
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
