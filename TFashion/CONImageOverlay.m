//
// Created by Seckin Can Sahin on 6/2/15.
//

#import "CONImageOverlay.h"


@implementation CONImageOverlay: UIView
@synthesize cloth_pieces;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 1.0);

    //NSArray *cloth_pieces = self.cloth_pieces;
    CGFloat x,y;
    float scale = 320.0 / 560.0;
    for(int i = 0; i < [cloth_pieces count]; i++) {
        PFObject *cloth_piece = [cloth_pieces objectAtIndex:i];
        NSMutableArray *boundary_points = [cloth_piece objectForKey:@"boundary_points"];
//        NSLog(@"BURDA2222: double click will trigger the drawing of a cloth piece with this many boundary points: %lu", (unsigned long)[boundary_points count]);

        x = (CGFloat)[boundary_points[0][0] floatValue];
        y = (CGFloat)[boundary_points[0][1] floatValue];
        CGContextMoveToPoint(context, x * scale, y * scale);
        for(int j = 1; j < [boundary_points count]; j++) {
            x = (CGFloat)[boundary_points[j][0] floatValue];
            y = (CGFloat)[boundary_points[j][1] floatValue];
//            NSLog(@"x,y = %lf, %lf", x,y);
            CGContextAddLineToPoint(context, x * scale, y * scale);
        }
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillPath(context);
    }
}

@end