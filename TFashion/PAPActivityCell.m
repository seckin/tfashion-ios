//
//  PAPActivityCell.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/14/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPActivityCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPProfileImageView.h"
#import "PAPActivityFeedViewController.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface PAPActivityCell ()

/*! Private view components */
@property (nonatomic, strong) PAPProfileImageView *activityImageView;
@property (nonatomic, strong) UIButton *activityImageButton;

/*! Flag to remove the right-hand side image if not necessary */
@property (nonatomic) BOOL hasActivityImage;

/*! Private setter for the right-hand side image */
- (void)setActivityImageFile:(PFFile *)image;

/*! Button touch handler for activity image button overlay */
- (void)didTapActivityButton:(id)sender;

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end

@implementation PAPActivityCell


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:0];
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        // Create subviews and set cell properties
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.hasActivityImage = NO; //No until one is set
        
        self.activityImageView = [[PAPProfileImageView alloc] init];
        [self.activityImageView setBackgroundColor:[UIColor whiteColor]];
        [self.activityImageView setOpaque:YES];
        [self.mainView addSubview:self.activityImageView];
        
        self.activityImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activityImageButton setBackgroundColor:[UIColor clearColor]];
        [self.activityImageButton addTarget:self action:@selector(didTapActivityButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.activityImageButton];
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
       
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    [self.activityImageView setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 13.0f, 33.0f, 33.0f)];
    [self.activityImageButton setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 13.0f, 33.0f, 33.0f)];

    // Add activity image if one was set
    if (self.hasActivityImage) {
        [self.activityImageView setHidden:NO];
        [self.activityImageButton setHidden:NO];
    } else {
        [self.activityImageView setHidden:YES];
        [self.activityImageButton setHidden:YES];
    }
    
    // Layout the name button
    CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:13.0f]}
                                                                    context:nil].size;
    [self.nameButton setFrame:CGRectMake(nameX, nameY + 6.0f, nameSize.width, nameSize.height)];

    // Change frame of the content text so it doesn't go through the right-hand side picture
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:13.0f]}
                                                    context:nil].size;
    [self.contentLabel setFrame:CGRectMake( 46.0f, 15.0f, contentSize.width, contentSize.height * 1.2)];

    // Layout the timestamp label given new vertical 
    CGSize timeSize = [self.timeLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - 46.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:11.0f]}
                                                    context:nil].size;
    [self.timeLabel setFrame:CGRectMake( 46.0f, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 7.0f, timeSize.width, timeSize.height)];
}


#pragma mark - PAPActivityCell

- (void)setIsNew:(BOOL)isNew {
    if (isNew) {
        [self.mainView setBackgroundColor:[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f]];
    } else {
        [self.mainView setBackgroundColor:[UIColor whiteColor]];
    }
}


- (void)setActivity:(PFObject *)activity {
    // Set the activity property
    _activity = activity;
    if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeFollow] || [[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
        [self setActivityImageFile:nil];
    } if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeMention]) {
        PFObject *comment = [activity objectForKey:kPAPActivityCommentKey];
        [comment fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                PFObject *photo = [object objectForKey:kPAPActivityPhotoKey];
                [photo fetchIfNeededInBackgroundWithBlock:^(PFObject *fetched_photo, NSError *error) {
                    [self setActivityImageFile:(PFFile*)[fetched_photo objectForKey:kPAPPhotoThumbnailKey]];
                    // *** TODO: fix below to show pictures on first page load
                    UITableViewController *vc = (UITableViewController *)[self getViewController];
//                    [vc.tableView reloadData];
                    [vc.tableView setNeedsDisplay];
                    [self setNeedsDisplay];
                    [CATransaction flush];
                }];
            }
        }];
    } else {
        PFObject *cloth = [activity objectForKey:kPAPActivityClothKey];

        [cloth fetchIfNeededInBackgroundWithBlock:^(PFObject *fetched_cloth, NSError *error) {
            PFObject *photo = [cloth objectForKey:kPAPClothPhotoKey];
            [photo fetchIfNeededInBackgroundWithBlock:^(PFObject *fetched_photo, NSError *error) {
                [self setActivityImageFile:(PFFile*)[fetched_photo objectForKey:kPAPPhotoThumbnailKey]];
                // *** TODO: fix below to show pictures on first page load
                UITableViewController *vc = (UITableViewController *)[self getViewController];
                [vc.tableView setNeedsDisplay];
                [self setNeedsDisplay];
                [CATransaction flush];
            }];
        }];
    }
    
    NSString *activityString = [PAPActivityFeedViewController stringForActivityType:(NSString*)[activity objectForKey:kPAPActivityTypeKey]];
    self.user = [activity objectForKey:kPAPActivityFromUserKey];
    
    // Set name button properties and avatar image
    if ([PAPUtility userHasProfilePictures:self.user]) {
        [self.avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    } else {
        [self.avatarImageView setImage:[PAPUtility defaultProfilePicture]];
    }

    NSString *nameString = NSLocalizedString(@"Someone", @"Text when the user's name is unknown");
    if (self.user && [self.user objectForKey:kPAPUserDisplayNameKey] && [[self.user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
        nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    }
    
    [self.nameButton setTitle:nameString forState:UIControlStateNormal];
    [self.nameButton setTitle:nameString forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }

    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:13.0f]}
                                                        context:nil].size;
        [self.nameButton setBackgroundColor:[UIColor whiteColor]];
        
        [self.nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self.nameButton setOpaque:YES];
        
        NSString *paddedString = [PAPBaseTextCell padString:activityString withFont:[UIFont fontWithName:@"Gotham-Book" size:13.0f] toWidth:nameSize.width];
        [self.contentLabel setText:paddedString];
        [self.contentLabel setTextColor:[UIColor blackColor]];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.contentLabel setText:activityString];
        [self.contentLabel setTextColor:[UIColor blackColor]];
    }

    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[activity createdAt]]];

    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    [super setCellInsetWidth:insetWidth];
    horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:insetWidth];
}

// Since we remove the compile-time check for the delegate conforming to the protocol
// in order to allow inheritance, we add run-time checks.
- (id<PAPActivityCellDelegate>)delegate {
    return (id<PAPActivityCellDelegate>)_delegate;
}

- (void)setDelegate:(id<PAPActivityCellDelegate>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
    }
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

#pragma mark - ()

+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return ([UIScreen mainScreen].bounds.size.width - (insetWidth * 2.0f)) - 72.0f - 46.0f;
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [self heightForCellWithName:name contentString:content cellInsetWidth:0.0f];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:13.0f]}
                                                    context:nil].size;
    NSString *paddedString = [PAPBaseTextCell padString:content withFont:[UIFont fontWithName:@"Gotham-Book" size:13.0f] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin // wordwrap?
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:13.0f]}
                                                    context:nil].size;

    CGFloat singleLineHeight = [@"Test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:13.0f]}
                                                    context:nil].size.height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = contentSize.height - singleLineHeight;

    return 58.0f + fmax(0.0f, multilineHeightAddition);
}

- (void)setActivityImageFile:(PFFile *)imageFile {
    if (imageFile) {
        [self.activityImageView setFile:imageFile];
        [self setHasActivityImage:YES];
    } else {
        [self setHasActivityImage:NO];
    }
}

- (void)didTapActivityButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapActivityButton:)]) {
        [self.delegate cell:self didTapActivityButton:self.activity];
    }    
}

@end
