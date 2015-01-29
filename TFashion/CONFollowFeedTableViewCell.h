//
//  CONFollowFeedTableViewCell.h
//  TFashion
//
//  Created by Utku Sakil on 1/28/15.
//
//

#import "CONFeedTableViewCell.h"

@protocol CONFollowFeedTableViewCellDelegate;

@interface CONFollowFeedTableViewCell : CONFeedTableViewCell

@property (strong, nonatomic) UIButton *followButton;

@property (nonatomic,weak) id <CONFollowFeedTableViewCellDelegate> delegate;

@end

@protocol CONFollowFeedTableViewCellDelegate <NSObject>

- (void)followFeedTableViewCellDidClickedFollowButton:(CONFollowFeedTableViewCell *)followFeedTableViewCell;

@end
