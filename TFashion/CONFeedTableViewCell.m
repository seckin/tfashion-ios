//
//  CONFeedTableViewCell.m
//  TFashion
//
//  Created by Utku Sakil on 12/23/14.
//
//

#import "CONFeedTableViewCell.h"

@implementation CONFeedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.titleLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    [self.titleLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
    [self.contentView addSubview:self.titleLabel];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.collectionView];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(10, 10, self.contentView.bounds.size.width-20, 20);
    self.collectionView.frame = CGRectMake(self.contentView.bounds.origin.x, CGRectGetMaxY(self.titleLabel.frame), self.contentView.bounds.size.width, self.contentView.bounds.size.height-CGRectGetMaxY(self.titleLabel.frame));
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}

@end
