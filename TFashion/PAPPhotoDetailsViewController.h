//
//  PAPPhotoDetailViewController.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPPhotoDetailsHeaderView.h"
#import "PAPBaseTextCell.h"
#import "MPGTextField.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface PAPPhotoDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, PAPPhotoDetailsHeaderViewDelegate, PAPBaseTextCellDelegate, MPGTextFieldDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) PFObject *photo;

- (id)initWithPhoto:(PFObject*)aPhoto;

@end
