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
@class CONTagDetailPopover;

@interface PAPPhotoCell : PFTableViewCell

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) CONImageOverlay *imageOverlay;
@property (nonatomic, strong) NSMutableArray *clothOverlays;
@property (nonatomic, strong) NSMutableArray *clothesDataArr;
@property (strong) CONDEMOTag *tag;
@property (strong) CONTagPopover *tagpopover;
@property (strong) CONTagDetailPopover *tagdetailpopover;

@end
