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
@synthesize clothesDataArr;


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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clothesDataArrUpdated:) name:@"clothesDataArrUpdated" object:nil];
    }

    return self;
}

- (void)clothesDataArrUpdated:(NSNotification *)note {
    NSDictionary *cloth_data = [self.clothesDataArr objectAtIndex:([self.clothesDataArr count] - 1)];
    NSArray *cloth_pieces = [cloth_data objectForKey:@"cloth_pieces"];

    PFObject *cloth_piece = [cloth_pieces objectAtIndex:0];
    NSMutableArray *boundary_points = [cloth_piece objectForKey:@"boundary_points"];

    CGFloat x,y, cum_x = 0.0f, cum_y = 0.0f, avg_x, avg_y;
    for(int j = 0; j < [boundary_points count]; j++) {
        cum_x += (CGFloat)[boundary_points[j][0] floatValue];
        cum_y += (CGFloat)[boundary_points[j][1] floatValue];
    }
    avg_x = cum_x / [boundary_points count];
    avg_y = cum_y / [boundary_points count];

    NSLog(@"clothesDataArrUpdated notification triggered/received");
    CONDEMOTag *tag = [CONDEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.0f, 0.0f)],
            @"tagText" : @""}];

    [self setTag:tag];

    self.tagpopover = [[CONTagPopover alloc] init];//[CONTagPopover initWithTag:self.tag];
    [self.tagpopover initWithTag:self.tag];

    float scale = 320.0 / 560.0;
    [self.tagpopover presentPopoverFromPoint:CGPointMake(avg_x * scale, avg_y * scale) inRect:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width) inView:self.contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:NO];

//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTagPopoverTapGesture:) ];
//    tapGesture.numberOfTapsRequired = 2;
//    [self.tagpopover addGestureRecognizer:tapGesture];
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
//    [self.imageOverlay removeFromSuperview];
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

#pragma mark - Actions

- (void)photoButtonDoubleTap:(id)sender
{
    // OK TODO: move the popover creation code to the notification handler (and change the name of the notification handler to something like cloth data updated)
    // OK TODO: fix the bug that results in showing too many cloths and cloths that are overlapping (might be on the ruby side)
    // OK TODO: show the real clothes of the image, not the clothes of a fixed image
    // OK TODO: fix the cloth size problem
    // TODO: only flash the correct cloth
    for(int i = 0; i < [self.clothesDataArr count]; i++) {
        NSDictionary *cloth_data = [self.clothesDataArr objectAtIndex:i];

        CONImageOverlay *imageOverlay = [[CONImageOverlay alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width)];
        imageOverlay.clothDataArr = cloth_data;

        POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
        animation.fromValue = @(0.0);
        animation.toValue = @(0.15);

        [imageOverlay pop_addAnimation:animation forKey:@"fadespring"];

        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self
                                       selector:@selector(removeImageOverlay:)
                                       userInfo:nil
                                        repeats:NO];

        [self.clothOverlays addObject:imageOverlay];
        [self addSubview:[self.clothOverlays objectAtIndex:([self.clothOverlays count] - 1)]];
    }

    [self setNeedsDisplay];
}

@end
