//
//  PAPFindFriendsCell.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "CONPhotoCaptionView.h"
#import "PAPProfileImageView.h"
#import "PAPBaseTextCell.h"
#import "PAPAccountViewController.h"
//#import "UIColor+CreateMethods.h"

@interface CONPhotoCaptionView ()
/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
//@property (nonatomic, strong) PFObject *photo;

@end


@implementation CONPhotoCaptionView
@synthesize photo;
@synthesize user;

#pragma mark - NSObject

- (id)initWithPhoto:(PFObject *)aPhoto {
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 400.0, 44.0)];
    if (self) {
        self.photo = aPhoto;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.user = [self.photo objectForKey:kPAPPhotoUserKey];

        PAPBaseTextCell *textArea = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        textArea.cellInsetWidth = 0.0f;//kPAPCellInsetWidth;
        textArea.delegate = self;
        textArea.contentLabel.delegate = self;
        textArea.contentLabel.userInteractionEnabled = YES;

        [textArea setUser:nil];
        [textArea setContentObject:self.photo];
        [textArea setContentText:[self.photo objectForKey:kPAPPhotoCaptionKey]];
//        [textArea setDate:[self.photo createdAt]];

        [self.contentView addSubview:textArea];
        [self.contentView layoutSubviews];
        [self setNeedsDisplay];
    }
    return self;
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


#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self shouldPresentAccountViewForUser:aUser];
}


- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [[self getViewController].navigationController pushViewController:accountViewController animated:YES];
}

- (UIViewController *)getViewController
{
    id vc = [self nextResponder];
    while(![vc isKindOfClass:[UIViewController class]] && vc!=nil)
    {
        vc = [vc nextResponder];
    }

    return vc;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    NSString *userObjectId = [url absoluteString];
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:userObjectId block:^(PFObject *object, NSError *error) {
        PFUser *user = (PFUser *)object;
        [self shouldPresentAccountViewForUser:user];
    }];
}






@end
