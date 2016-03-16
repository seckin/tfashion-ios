
#import <UIKit/UIKit.h>

/*CONTagPopover is a UIView subclass that displays the text for a tag
 within a callout bubble coming from a specific point in a photo*/

@interface CONTagPopover : UIView <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (assign) CGPoint normalizedArrowPoint;
@property (assign) CGPoint normalizedArrowOffset;
@property (assign) CGSize minimumTextFieldSize;
@property (assign) CGSize minimumTextFieldSizeWhileEditing;
@property (assign) NSInteger maximumTextLength; //set to 0 for no limit on a tag's length.

@property (nonatomic, strong, readonly) PFObject *photo;
@property (nonatomic, strong, readonly) PFObject *cloth;

- (id)initWithPhoto:(PFObject*)aPhoto cloth:(PFObject *)cloth;

- (NSString *)text;
- (void)setText:(NSString *)text;

- (void)presentPopoverFromPoint:(CGPoint)point
                         inView:(UIView *)view
                       animated:(BOOL)animated;

- (void)presentPopoverFromPoint:(CGPoint)point
                         inView:(UIView *)view
       permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                       animated:(BOOL)animated;

- (void)presentPopoverFromPoint:(CGPoint)point
                         inRect:(CGRect)rect
                         inView:(UIView *)view
       permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                       animated:(BOOL)animated;

- (void)repositionInRect:(CGRect)rect;


@end






