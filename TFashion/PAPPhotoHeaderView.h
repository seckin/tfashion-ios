//
//  PAPPhotoHeaderView.h
//  Anypic
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

typedef enum {
    PAPPhotoHeaderButtonsNone = 0,
    PAPPhotoHeaderButtonsUser = 1 << 0,
    PAPPhotoHeaderButtonsDefault = PAPPhotoHeaderButtonsUser
} PAPPhotoHeaderButtons;

@protocol PAPPhotoHeaderViewDelegate;

@interface PAPPhotoHeaderView : UITableViewCell

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame buttons:(PAPPhotoHeaderButtons)otherButtons;

/// The photo associated with this view
@property (nonatomic,strong) PFObject *photo;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) PAPPhotoHeaderButtons buttons;

/*! @name Delegate */
@property (nonatomic,weak) id <PAPPhotoHeaderViewDelegate> delegate;

@end

/*!
 The protocol defines methods a delegate of a PAPPhotoHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol PAPPhotoHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)photoHeaderView:(PAPPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end