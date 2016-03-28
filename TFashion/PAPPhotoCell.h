
#import <ParseUI/ParseUI.h>

@class PFImageView;
@class CONImageOverlay;
@class CONTagPopover;
@class PAPBaseTextCell;

@interface PAPPhotoCell : PFTableViewCell

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) PAPBaseTextCell *captioncell;
@property (nonatomic, strong) UIButton *photoButton;
// flashing part:
@property (nonatomic, strong) CONImageOverlay *imageOverlay;
// holds all flashing parts. this is buggy. this has to be implemented as an array of arrays, each array holding one cloth's all cloth_pieces (each cloth piece needs a separate CONImageOverlay instance):
@property (nonatomic, strong) NSMutableArray *clothOverlays;
// holds one popover for each cloth. indexes align
@property (nonatomic, strong) NSMutableArray *tagPopovers;

- (void)saveUserLike:(PFObject *)cloth;

@end
