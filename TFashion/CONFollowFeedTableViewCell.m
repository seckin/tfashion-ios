//
//  CONFollowFeedTableViewCell.m
//  TFashion
//
//  Created by Utku Sakil on 1/28/15.
//
//

#import "CONFollowFeedTableViewCell.h"
#import <FontAwesomeKit/FAKFontAwesome.h>
#import "UIColor+InitAdditions.h"

@implementation CONFollowFeedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.textColor = [UIColor whiteColor];
    
    // Set follow button
    FAKFontAwesome *followIcon = [FAKFontAwesome plusSquareOIconWithSize:20.0f];
    [followIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    FAKFontAwesome *checkIcon = [FAKFontAwesome checkSquareOIconWithSize:20.0f];
    [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:@"#16a9c7" alpha:1.0f]];
    
    _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_followButton setImage:[followIcon imageWithSize:CGSizeMake(20.0f, 20.0f)] forState:UIControlStateNormal];
    [_followButton setImage:[checkIcon imageWithSize:CGSizeMake(20.0f, 20.0f)] forState:UIControlStateSelected];
    [_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_followButton];
    
    // Gesture recognizer for collection view
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followButtonAction:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    [self.collectionView addGestureRecognizer:tapRecognizer];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(10, 10, self.contentView.bounds.size.width - 50, 20);
    self.followButton.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 30, 10, 20, 20);
}

#pragma mark - Actions

- (void)followButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(followFeedTableViewCellDidClickedFollowButton:)]) {
        [self.delegate followFeedTableViewCellDidClickedFollowButton:self];
    }
}

@end
