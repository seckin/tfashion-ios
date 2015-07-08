//
//  PAPPhotoCell.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@class PFImageView;
@class CONImageOverlay;
@class CONDEMOTag;
@class CONTagPopover;

@interface PAPPhotoCell : PFTableViewCell

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) CONImageOverlay *imageOverlay;
@property (nonatomic, strong) NSMutableArray *clothOverlays;
@property (nonatomic, strong) CONTagPopover *popover1;
@property (nonatomic, strong) CONTagPopover *popover2;
@property (nonatomic, strong) CONTagPopover *popover3;

@end
