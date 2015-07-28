//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "CONTagPopover.h"
//#import "EBPhotoPagesController.h"
//#import "EBPhotoPagesNotifications.h"
#import <QuartzCore/QuartzCore.h>


@interface CONTagPopover ()
@property (weak) UIView *contentView;
@property (weak) UITextField *tagTextField;
@property (assign) UIButton *commentButton;
@property (assign) UIButton *likeButton;
@property (assign, getter = isCanceled) BOOL canceled;
@end

#pragma mark - EBTagPopover

@implementation CONTagPopover

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithTag:(id<CONPhotoTagProtocol>)aTag
{
    self = [super init];
    if(self){
        NSAssert([(NSObject *)aTag conformsToProtocol:@protocol(CONPhotoTagProtocol)],
                 @"A tag's data source must conform to CONPhotoTagProtocol.");
        [self initialize];
        [self setDataSource:aTag];
        [self setText:self.dataSource.tagText];
    }
    return self;
}

- (void)initialize
{
    [self loadContentView];
    [self loadGestureRecognizers];
    
    CGSize tagInsets = CGSizeMake(-7, -6);
    CGRect tagBounds = CGRectInset(self.contentView.bounds, tagInsets.width, tagInsets.height);
    tagBounds.size.height += 0.0f;
    tagBounds.origin.x = 0;
    tagBounds.origin.y = 0;
    
    [self setFrame:tagBounds];
    
    [self setMinimumTextFieldSize:CGSizeMake(25, 14)];
    [self setMinimumTextFieldSizeWhileEditing:CGSizeMake(54, 14)];
    [self setMaximumTextLength:40];
    
    [self setNormalizedArrowOffset:CGPointMake(0.0, 0.02)];
    
    [self setOpaque:NO];
    [self.contentView setFrame:CGRectOffset(self.contentView.frame,
                                            -(tagInsets.width),
                                            -(tagInsets.height)+0)];
    
    [self beginObservations];
}

- (void)dealloc
{
    [self stopObservations];
}

#pragma mark -

- (void)loadContentView
{
    UIView *contentView = [self newContentView];
    [self addSubview:contentView];
    [self setContentView:contentView];
}

- (void)loadGestureRecognizers
{
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(didRecognizeSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    
    [self addGestureRecognizer:singleTapGesture];
}

- (UIView *)newContentView
{
    NSString *placeholderText = NSLocalizedString(@"New Tag",
                                                  @"Appears as placeholder text before a user enters text for a photo tag.");
    UIFont *textFieldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    CGSize tagSize = [placeholderText sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]}];

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, tagSize.width, tagSize.height)];
    [textField setFont:textFieldFont];
    [textField setBackgroundColor:[UIColor clearColor]];
    [textField setTextColor:[UIColor blackColor]];
//    [textField setPlaceholder:placeholderText];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setEnablesReturnKeyAutomatically:YES];
    [textField setDelegate:self];
    [textField setUserInteractionEnabled:NO];

    [self setTagTextField:textField];
    return textField;
}


#pragma mark - Notifications

- (void)beginObservations
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tagTextFieldDidChangeWithNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveCancelNotification:)
//                                                 name:EBPhotoPagesControllerDidCancelTaggingNotification object:nil];
}


- (void)stopObservations
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)tagTextFieldDidChangeWithNotification:(NSNotification *)aNotification
{
    //resize, reposition
    if(aNotification.object == self.tagTextField){
        [self resizeTextField];
    }
}


- (NSString *)text
{
    return self.tagTextField.text;
}

- (void)setText:(NSString *)text
{
    NSLog(@"setText called with text = %@", text);
    [self.tagTextField setText:text];
    [self resizeTextField];
}

- (void)presentPopoverFromPoint:(CGPoint)point
                         inView:(UIView *)view
                       animated:(BOOL)animated
{
    [self presentPopoverFromPoint:point
                           inRect:view.frame
                           inView:view
         permittedArrowDirections:UIPopoverArrowDirectionUp
                         animated:animated];
}



- (void)presentPopoverFromPoint:(CGPoint)point
                         inView:(UIView *)view
       permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                       animated:(BOOL)animated
{
    [self presentPopoverFromPoint:point
                           inRect:view.frame
                           inView:view
         permittedArrowDirections:arrowDirections
                         animated:animated];
}


- (void)presentPopoverFromPoint:(CGPoint)point
                         inRect:(CGRect)rect
                         inView:(UIView *)view
       permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                       animated:(BOOL)animated;
{
    //[self setCenter:point];
    
    [view addSubview:self];
    
    CGPoint difference = CGPointMake(0,//(newCenter.x - point.x)/self.frame.size.width,
                                     0.5);
    
    [self.layer setAnchorPoint:CGPointMake(0.5-difference.x,0.5-difference.y)];
    
    [self setCenter:point];
    
    CGFloat tagMaximumX = CGRectGetMaxX(self.frame);
    CGFloat tagMinimumX = CGRectGetMinX(self.frame);
    CGFloat tagMaximumY = CGRectGetMaxY(self.frame);
    CGFloat tagMinimumY = CGRectGetMinY(self.frame);
    
    CGRect tagBoundary = CGRectInset(view.frame, 5, 5);
    CGFloat boundsMinimumX = CGRectGetMinX(tagBoundary);
    CGFloat boundsMaximumX = CGRectGetMaxX(tagBoundary);
    CGFloat boundsMinimumY = CGRectGetMinY(tagBoundary);
    CGFloat boundsMaximumY = CGRectGetMaxY(tagBoundary);
    
    CGFloat xOffset = ((MIN(0, tagMinimumX - boundsMinimumX) + MAX(0, tagMaximumX - boundsMaximumX))/1.0);
    CGFloat yOffset = ((MIN(0, tagMinimumY - boundsMinimumY) + MAX(0, tagMaximumY - boundsMaximumY))/1.0);
    
    
    CGPoint newCenter = CGPointMake(point.x - xOffset,
                                    point.y - yOffset);
    
    [self setCenter:newCenter];
}


- (void)drawRect:(CGRect)fullRect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    float radius = 8.0f;
    float arrowHeight =  5.0f; //this is how far the arrow extends from the rect
    float arrowWidth = 10.0;
    
    fullRect = CGRectInset(fullRect, 1, 1);
    
    CGRect containerRect = CGRectMake(fullRect.origin.x,
                                      fullRect.origin.y+arrowHeight,
                                      fullRect.size.width,
                                      fullRect.size.height-arrowHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    CGMutablePathRef tagPath = CGPathCreateMutable();
    
    //the starting point, top left corner
    CGPathMoveToPoint(tagPath, NULL, CGRectGetMinX(containerRect) + radius, CGRectGetMinY(containerRect));
    
    //draw the arrow
    CGPathAddLineToPoint(tagPath, NULL, CGRectGetMidX(containerRect)-(arrowWidth*0.5), CGRectGetMinY(containerRect));
    CGPathAddLineToPoint(tagPath, NULL, CGRectGetMidX(containerRect), CGRectGetMinY(fullRect));
    CGPathAddLineToPoint(tagPath, NULL, CGRectGetMidX(containerRect)+(arrowWidth*0.5), CGRectGetMinY(containerRect));
    
    //top right corner
    CGPathAddArc(tagPath, NULL, CGRectGetMaxX(containerRect) - radius, CGRectGetMinY(containerRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    
    //bottom right corner
    CGPathAddArc(tagPath, NULL, CGRectGetMaxX(containerRect) - radius, CGRectGetMaxY(containerRect) - radius, radius, 0, (float)M_PI / 2, 0);
    
    //bottom left corner
    CGPathAddArc(tagPath, NULL, CGRectGetMinX(containerRect) + radius, CGRectGetMaxY(containerRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    
    //top left corner, the ending point
    CGPathAddArc(tagPath, NULL, CGRectGetMinX(containerRect) + radius, CGRectGetMinY(containerRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    
    //we are done
    CGPathCloseSubpath(tagPath);
    
    
    
    CGContextAddPath(context, tagPath);
    //CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 1.5, [[UIColor colorWithRed:0 green:0 blue:20/255.0 alpha:0.35] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.11 alpha:0.75] CGColor]);
    
    
    CGContextFillPath(context);
    
    //Draw stroke
    CGContextAddPath(context, tagPath);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.85 alpha:1] CGColor]);
    CGContextSetLineWidth(context, 1);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextStrokePath(context);
    
    
    
    //CGContextAddPath(context, tagPath);
    
    
    //CGPathRelease(arrowPath);
    CGPathRelease(tagPath);
    CGColorSpaceRelease(colorSpace);
    
}

- (void)repositionInRect:(CGRect)rect
{
    NSLog(@"repositionInRect called");
    [self.layer setAnchorPoint:CGPointMake(0.5,0)];
    CGPoint popoverPoint = CGPointMake(rect.origin.x, rect.origin.y);
    popoverPoint.x += rect.size.width * (self.normalizedArrowPoint.x + self.normalizedArrowOffset.x);
    popoverPoint.y += rect.size.height * (self.normalizedArrowPoint.y + self.normalizedArrowOffset.y);
    
    [self setCenter:popoverPoint];
    
    CGFloat rightX = self.frame.origin.x+self.frame.size.width;
    CGFloat leftXClip = MAX(rect.origin.x - self.frame.origin.x, 0);
    CGFloat rightXClip = MIN((rect.origin.x+rect.size.width)-rightX, 0);
    
    CGRect newFrame = self.frame;
    newFrame.origin.x += leftXClip;
    newFrame.origin.x += rightXClip;
    
    [self setFrame:newFrame];
    
    
}

#pragma mark - Event Hooks

- (void)didRecognizeSingleTap:(UITapGestureRecognizer *)tapGesture
{
    if(self.isFirstResponder == NO){
//        [self.delegate tagPopover:self didReceiveSingleTap:tapGesture];
    }
}

- (void)didReceiveCancelNotification:(NSNotification *)aNotification
{
    if(self.isFirstResponder){
        [self setCanceled:YES];
        [self resignFirstResponder];
        [self removeFromSuperview];
    }
}

#pragma mark - UITextField Delegate


- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    BOOL result = NO;
    
    if(textField == self.tagTextField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if((!self.maximumTextLength) || (newLength <= self.maximumTextLength)){
            result = YES;
        }
    }
    
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.tagTextField){
        [textField setTextAlignment:NSTextAlignmentLeft];
        [self resizeTextField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.tagTextField){
        [textField setTextAlignment:NSTextAlignmentCenter];
        [self resizeTextField];
        if([self isCanceled] == NO){
//            [self.delegate tagPopoverDidEndEditing:self];
        }
        [self resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.tagTextField){
        [self resignFirstResponder];
    }
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [self.tagTextField setUserInteractionEnabled:YES];
    if([self.tagTextField canBecomeFirstResponder]){
        [self.tagTextField becomeFirstResponder];
        [self resizeTextField];
        return YES;
    }
    
    [self.tagTextField setUserInteractionEnabled:NO];
    return NO;
}

- (BOOL)isFirstResponder
{
    return self.tagTextField.isFirstResponder;
}

- (BOOL)resignFirstResponder
{
    [self.tagTextField setUserInteractionEnabled:NO];
    return self.tagTextField.resignFirstResponder;
}

# pragma mark -

- (void)resizeTextField
{
    int iconFontSize = 16.0f;
    int countFontSize = 10.0f;
    int likeCount = 2;
    int commentCount = 1;
    NSString *countTexts = [NSString stringWithFormat:@"%d%d",likeCount, commentCount];
    CGSize countTextsSize = [countTexts sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:countFontSize]}];
    
    CGSize newTagSize = countTextsSize;
    // allocate space for icons:
    newTagSize.width += iconFontSize * 2 + 20;
    newTagSize.height += 6;

    CGRect newTextFieldFrame = self.tagTextField.frame;
    newTextFieldFrame.size.width = newTagSize.width;
    newTextFieldFrame.size.height = newTagSize.height;
    [self.tagTextField setFrame:newTextFieldFrame];

    CGSize tagInsets = CGSizeMake(-7, -6);
    CGRect tagBounds = CGRectInset(self.tagTextField.bounds, tagInsets.width, tagInsets.height);
    tagBounds.size.height += 0.0f;
    tagBounds.origin.x = 0;
    tagBounds.origin.y = 0;

    CGPoint originalCenter = self.center;

    [self setFrame:tagBounds];
    
    // add heart icon
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setFrame:CGRectMake(0.0f, 3.0f, iconFontSize, iconFontSize)];
    [self.likeButton setBackgroundColor:[UIColor clearColor]];
    [self.likeButton setAdjustsImageWhenHighlighted:NO];
    [self.likeButton setAdjustsImageWhenDisabled:NO];
    FAKIonIcons *likeIcon = [FAKIonIcons iosHeartOutlineIconWithSize:iconFontSize];
    [likeIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:247.0f/255.0f green:50.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
    [self.likeButton setBackgroundImage:[likeIcon imageWithSize:CGSizeMake(iconFontSize, iconFontSize)] forState:UIControlStateNormal];
    FAKIonIcons *likeIconSelected = [FAKIonIcons iosHeartIconWithSize:iconFontSize];
    [likeIconSelected addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:247.0f/255.0f green:50.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
    [self.likeButton setBackgroundImage:[likeIconSelected imageWithSize:CGSizeMake(iconFontSize, iconFontSize)] forState:UIControlStateSelected];
    [self.likeButton setSelected:NO];
    [self.tagTextField addSubview:self.likeButton];
    
    // add like count
    UILabel *likeCountLabel = [[UILabel alloc] init];
    NSString *likeCountText = [NSString stringWithFormat:@"%d", likeCount];
    likeCountLabel.text = likeCountText;
    [likeCountLabel sizeToFit];
    [likeCountLabel setTextColor:[UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:254.0f/255.0f alpha:1.0f]];
    [likeCountLabel setFont:[UIFont systemFontOfSize:countFontSize]];
    [likeCountLabel setFrame:CGRectMake( 18.0, 3.0f, 16.0f, 16.0f)];
    [self.tagTextField addSubview:likeCountLabel];
    
    // add comment icon
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentButton setFrame:CGRectMake( 32.0, 3.0f, iconFontSize, iconFontSize)];
    [self.commentButton setBackgroundColor:[UIColor clearColor]];
    FAKIonIcons *commentIcon = [FAKIonIcons iosChatbubbleOutlineIconWithSize:iconFontSize];
    [commentIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:254.0f/255.0f alpha:1.0f]];
    [self.commentButton setBackgroundImage:[commentIcon imageWithSize:CGSizeMake(iconFontSize, iconFontSize)] forState:UIControlStateNormal];
    [self.commentButton setSelected:NO];
    [self.tagTextField addSubview:self.commentButton];

    // add comment count
    UILabel *commentCountLabel = [[UILabel alloc] init];
    NSString *commentCountText = [NSString stringWithFormat:@"%d", commentCount];
    commentCountLabel.text = commentCountText;
    [commentCountLabel sizeToFit];
    [commentCountLabel setTextColor:[UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:254.0f/255.0f alpha:1.0f]];
    [commentCountLabel setFont:[UIFont systemFontOfSize:countFontSize]];
    [commentCountLabel setFrame:CGRectMake( 48.0, 3.0f, 16.0f, 16.0f)];
    [self.tagTextField addSubview:commentCountLabel];


    [self setCenter:originalCenter];

    [self setNeedsDisplay];
}



@end
