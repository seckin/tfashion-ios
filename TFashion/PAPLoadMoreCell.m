//
//  PAPLoadMoreCell.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPLoadMoreCell.h"
#import "PAPUtility.h"

@implementation PAPLoadMoreCell

@synthesize cellInsetWidth;
@synthesize mainView;
@synthesize separatorImageTop;
@synthesize separatorImageBottom;
@synthesize loadMoreImageView;
@synthesize hideSeparatorTop;
@synthesize hideSeparatorBottom;


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.cellInsetWidth = 0.0f;
        hideSeparatorTop = NO;
        hideSeparatorBottom = NO;

        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        if ([reuseIdentifier isEqualToString:@"NextPageDetails"]) {
            [mainView setBackgroundColor:[UIColor whiteColor]];
        } else {
            [mainView setBackgroundColor:[UIColor whiteColor]];
        }
        
        FAKIonIcons *loadMoreIcon = [FAKIonIcons iosMoreIconWithSize:31.0f];
        [loadMoreIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
        self.loadMoreImageView = [[UIImageView alloc] initWithImage:[loadMoreIcon imageWithSize:CGSizeMake(31.0f, 31.0f)]];
        [self.loadMoreImageView setFrame:CGRectMake(10.0f, 10.0f, 31.0f, 31.0f)];
        [mainView addSubview:self.loadMoreImageView];
        
        [self.contentView addSubview:mainView];
    }
    
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [mainView setFrame:CGRectMake( self.cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width-2*self.cellInsetWidth, self.contentView.frame.size.height)];
    
    // Layout load more text
    [self.loadMoreImageView setFrame:CGRectMake(144.5f, 10.0f, 31.0f, 31.0f)];

    // Layout separator
    [self.separatorImageBottom setFrame:CGRectMake( 0.0f, self.frame.size.height - 2.0f, self.frame.size.width-self.cellInsetWidth * 2.0f, 2.0f)];
    [self.separatorImageBottom setHidden:hideSeparatorBottom];
    
    [self.separatorImageTop setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - self.cellInsetWidth * 2.0f, 2.0f)];
    [self.separatorImageTop setHidden:hideSeparatorTop];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}


#pragma mark - PAPLoadMoreCell

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    cellInsetWidth = insetWidth;
    [mainView setFrame:CGRectMake( insetWidth, mainView.frame.origin.y, mainView.frame.size.width - 2.0f * insetWidth, mainView.frame.size.height)];
    [self setNeedsDisplay];
}

@end
