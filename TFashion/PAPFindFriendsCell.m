//
//  PAPFindFriendsCell.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPFindFriendsCell.h"
#import "PAPProfileImageView.h"

@interface PAPFindFriendsCell ()
/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *avatarImageButton;
@property (nonatomic, strong) PAPProfileImageView *avatarImageView;

@end


@implementation PAPFindFriendsCell
@synthesize delegate;
@synthesize user;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize photoLabel;
@synthesize followButton;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.avatarImageView = [[PAPProfileImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f);
        [self.contentView addSubview:self.avatarImageView];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.avatarImageButton.backgroundColor = [UIColor clearColor];
        self.avatarImageButton.frame = CGRectMake( 10.0f, 14.0f, 40.0f, 40.0f);
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:)
                         forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.avatarImageButton];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nameButton.backgroundColor = [UIColor clearColor];
        self.nameButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.nameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.nameButton setTitleColor:[UIColor darkGrayColor]
                              forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor lightGrayColor]
                              forState:UIControlStateHighlighted];
        [self.nameButton setTitleShadowColor:[UIColor whiteColor]
                                    forState:UIControlStateNormal];
        [self.nameButton setTitleShadowColor:[UIColor whiteColor]
                                    forState:UIControlStateSelected];
        [self.nameButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nameButton];
        
        self.photoLabel = [[UILabel alloc] init];
        self.photoLabel.font = [UIFont systemFontOfSize:11.0f];
        self.photoLabel.textColor = [UIColor grayColor];
        self.photoLabel.backgroundColor = [UIColor clearColor];
        self.photoLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        self.photoLabel.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        [self.contentView addSubview:self.photoLabel];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.followButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.followButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f);
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"ButtonFollow.png"]
                                     forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"BackgroundTabBar"]
                                     forState:UIControlStateSelected];
        FAKFoundationIcons *plusIcon = [FAKFoundationIcons plusIconWithSize:15.0f];
        [plusIcon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTabBar"]]];
        [self.followButton setImage:[plusIcon imageWithSize:CGSizeMake(15.0f, 15.0f)] forState:UIControlStateNormal];
        FAKFoundationIcons *checkIcon = [FAKFoundationIcons checkIconWithSize:15.0f];
        [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        [self.followButton setImage:[checkIcon imageWithSize:CGSizeMake(15.0f, 15.0f)]
                           forState:UIControlStateSelected];
        [self.followButton setTitle:NSLocalizedString(@"Follow  ", @"Follow string, with spaces added for centering")
                           forState:UIControlStateNormal];
        [self.followButton setTitle:@"Following"
                           forState:UIControlStateSelected];
        [self.followButton setTitleColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTabBar"]]
                                forState:UIControlStateNormal];
        [self.followButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateSelected];
        [self.followButton addTarget:self action:@selector(didTapFollowButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        self.followButton.clipsToBounds = YES;
        self.followButton.layer.cornerRadius = 5.0f;
        self.followButton.layer.borderWidth = 1.0f;
        self.followButton.layer.borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundTabBar"]].CGColor;
        [self.contentView addSubview:self.followButton];
    }
    return self;
}


#pragma mark - PAPFindFriendsCell

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Configure the cell
    [avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    
    // Set name 
    NSString *nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    CGSize nameSize = [nameString boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]}
                                                    context:nil].size;
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];

    [nameButton setFrame:CGRectMake( 60.0f, 17.0f, nameSize.width, nameSize.height)];
    
    // Set photo number label
    CGSize photoLabelSize = [@"photos" boundingRectWithSize:CGSizeMake(144.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                    context:nil].size;
    [photoLabel setFrame:CGRectMake( 60.0f, 17.0f + nameSize.height, 140.0f, photoLabelSize.height)];
    
    // Set follow button
    [followButton setFrame:CGRectMake( 208.0f, 20.0f, 103.0f, 32.0f)];
}

#pragma mark - ()

+ (CGFloat)heightForCell {
    return 67.0f;
}

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }    
}

/* Inform delegate that the follow button was tapped */
- (void)didTapFollowButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapFollowButton:)]) {
        [self.delegate cell:self didTapFollowButton:self.user];
    }        
}

@end
