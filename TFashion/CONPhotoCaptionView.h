//
//  PAPFindFriendsCell.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPBaseTextCell.h"
@class CONPhotoCaptionView;

@protocol CONPhotoCaptionViewDelegate;

@interface CONPhotoCaptionView : UITableViewCell <TTTAttributedLabelDelegate>


/*! The user represented in the cell */
@property (nonatomic, strong) PFObject *user;
@property (nonatomic, strong) PFObject *photo;


- (void)didTapUserButtonAction:(id)sender;
- (id)initWithPhoto:(PFObject*)aPhoto;

/*! Static Helper methods */
+ (CGFloat)heightForCell;

/*! @name Delegate */
@property (nonatomic,strong) id <CONPhotoCaptionViewDelegate> delegate;


@end

/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol CONPhotoCaptionViewDelegate <PAPBaseTextCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser;

@end