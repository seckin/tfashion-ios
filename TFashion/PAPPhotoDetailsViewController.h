//
//  PAPPhotoDetailViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoDetailsHeaderView.h"
#import "PAPBaseTextCell.h"
#import "CONCommentTextView.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface PAPPhotoDetailsViewController : PFQueryTableViewController <UIActionSheetDelegate, PAPPhotoDetailsHeaderViewDelegate, PAPBaseTextCellDelegate, TTTAttributedLabelDelegate, CONCommentTextViewDelegate>

@property (nonatomic, strong) PFObject *photo;

- (id)initWithPhoto:(PFObject*)aPhoto;

@end
