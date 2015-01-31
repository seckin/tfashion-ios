//
//  CONFeedCollectionViewCell.m
//  TFashion
//
//  Created by Utku Sakil on 1/30/15.
//
//

#import "CONFeedCollectionViewCell.h"

@implementation CONFeedCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.imageView = [[UIImageView alloc] init];

    [self.contentView addSubview:self.imageView];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

#pragma mark - Public

+ (CGSize)sizeForCell
{
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat itemWidth = (screenWidth - 2*10)/3;
    return CGSizeMake(itemWidth, itemWidth);
}

@end
