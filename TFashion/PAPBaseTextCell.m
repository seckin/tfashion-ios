//
//  PAPBaseTextCell.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPBaseTextCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPProfileImageView.h"
#import "PAPUtility.h"
#import "CONTag.h"
#import "PAPCache.h"

static TTTTimeIntervalFormatter *timeFormatter;

@interface PAPBaseTextCell () {
    BOOL hideSeparator; // True if the separator shouldn't be shown
}

/* Private static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;
@end

@implementation PAPBaseTextCell

@synthesize mainView;
@synthesize cellInsetWidth;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize contentLabel;
@synthesize timeLabel;
@synthesize separatorImage;
@synthesize delegate;
@synthesize user;


#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        cellInsetWidth = 0.0f;
        hideSeparator = NO;
        self.clipsToBounds = YES;
        horizontalTextSpace =  [PAPBaseTextCell horizontalTextSpaceForInsetWidth:cellInsetWidth];
        
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [mainView setBackgroundColor:[UIColor whiteColor]];

        self.avatarImageView = [[PAPProfileImageView alloc] init];
        [self.avatarImageView setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageView setOpaque:YES];
        self.avatarImageView.layer.cornerRadius = 16.0f;
        self.avatarImageView.layer.masksToBounds = YES;
        [mainView addSubview:self.avatarImageView];
                
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];

        if ([reuseIdentifier isEqualToString:@"ActivityCell"]) {
            [self.nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.nameButton setTitleColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        } else {
            [self.nameButton setTitleColor:[UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.nameButton setTitleColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        }
        [self.nameButton.titleLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:13.0f]];
        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:self.nameButton];
        
        self.contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [self.contentLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:13.0f]];
        if ([reuseIdentifier isEqualToString:@"ActivityCell"]) {
            [self.contentLabel setTextColor:[UIColor blackColor]];
        } else {
            [self.contentLabel setTextColor:[UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f]];
        }
        [self.contentLabel setNumberOfLines:0];
        [self.contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.contentLabel setBackgroundColor:[UIColor clearColor]];
        UIColor *patternColor = [UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
        self.contentLabel.linkAttributes = [NSDictionary dictionaryWithObject:(__bridge id)[patternColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
        [mutableActiveLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [mutableActiveLinkAttributes setValue:(__bridge id)[patternColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.1f] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
        self.contentLabel.activeLinkAttributes = mutableActiveLinkAttributes;
        [mainView insertSubview:self.contentLabel belowSubview:self.nameButton];
        
        self.timeLabel = [[UILabel alloc] init];
        [self.timeLabel setFont:[UIFont fontWithName:@"Gotham-Book" size:11.0f]];
        [self.timeLabel setTextColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:self.timeLabel];
        
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        if(self.user) {
            [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }

        [mainView addSubview:self.avatarImageButton];
        
//        self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
//        [mainView addSubview:separatorImage];
        
        [self.contentView addSubview:mainView];
    }
    
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [mainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width-2*cellInsetWidth, self.contentView.frame.size.height)];
    
    // Layout avatar image
    [self.avatarImageView setFrame:CGRectMake(avatarX, avatarY + 5.0f, avatarDim, avatarDim)];
    [self.avatarImageButton setFrame:CGRectMake(avatarX, avatarY + 5.0f, avatarDim, avatarDim)];


    // Layout the name button
    CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:13.0f]}
                                                    context:nil].size;
    [self.nameButton setFrame:CGRectMake(nameX, nameY + 4.0f, nameSize.width, nameSize.height)];


    // Layout the content
    CGSize maxSize = CGSizeMake(horizontalTextSpace, CGFLOAT_MAX);
    CGSize requiredSize = [self.contentLabel sizeThatFits:maxSize];
    if(self.user) {
        self.contentLabel.frame = CGRectMake(nameX, vertTextBorderSpacing + 5.0f, requiredSize.width, requiredSize.height);
    } else {
        // if we are showing caption, not a comment, don't put too much X padding:
        self.contentLabel.frame = CGRectMake(avatarX, vertTextBorderSpacing + 5.0f, requiredSize.width, requiredSize.height);
    };

    // Layout the timestamp label
    CGSize timeSize = [self.timeLabel.text boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:11.0f]}
                                                    context:nil].size;
    [self.timeLabel setFrame:CGRectMake(timeX, contentLabel.frame.origin.y + contentLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];
    
    // Layour separator
    [self.separatorImage setFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width-cellInsetWidth*2, 1)];
    [self.separatorImage setHidden:hideSeparator];
}

#pragma mark - Delegate methods

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }    
}


#pragma mark - PAPBaseTextCell

/* Static helper to get the height for a cell if it had the given name and content */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [PAPBaseTextCell heightForCellWithName:name contentString:content cellInsetWidth:0];
}

/* Static helper to get the height for a cell if it had the given name, content and horizontal inset */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:nameSize
                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:13.0f]}
                                                    context:nil].size;

    NSString *paddedString = [PAPBaseTextCell padString:content withFont:[UIFont fontWithName:@"Gotham-Book" size:13] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [PAPBaseTextCell horizontalTextSpaceForInsetWidth:cellInset];
   
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:13.0f]}
                                                    context:nil].size;

    CGFloat singleLineHeight = [@"test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:13.0f]}
                                                     context:nil].size.height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = (contentSize.height - singleLineHeight) > 0 ? (contentSize.height - singleLineHeight) : 0;
    
    return horiBorderSpacing + avatarDim + horiBorderSpacingBottom + multilineHeightAddition;
}

/* Static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return (320-(insetWidth*2)) - (horiBorderSpacing+avatarDim+horiElemSpacing+horiBorderSpacing);
}

/* Static helper to pad a string with spaces to a given beginning offset */
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width {
    // Find number of spaces to pad
    NSMutableString *paddedString = [[NSMutableString alloc] init];
    while (true) {
        [paddedString appendString:@" "];
        CGSize resultSize = [paddedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:font}
                                                        context:nil].size;
        if (resultSize.width >= width) {
            break;
        }
    }
    
    // Add final spaces to be ready for first word
    [paddedString appendString:[NSString stringWithFormat:@" %@",string]];
    return paddedString;
}

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Set name button properties and avatar image
    if ([PAPUtility userHasProfilePictures:self.user]) {
        [self.avatarImageView setFile:[self.user objectForKey:kPAPUserProfilePicSmallKey]];
    } else {
        [self.avatarImageView setImage:[PAPUtility defaultProfilePicture]];
    }

    [self.nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }
    [self setNeedsDisplay];
}

- (void)setContentText:(NSString *)contentString {
    // If we have a user we pad the content with spaces to make room for the name
    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Medium" size:13.0f]}
                                                        context:nil].size;
        NSString *paddedString = [PAPBaseTextCell padString:contentString withFont:[UIFont fontWithName:@"Gotham-Book" size:13] toWidth:nameSize.width];
        [self.contentLabel setText:paddedString];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.contentLabel setText:contentString];
    }
    
    // Set tags
//    if (self.contentObject) {
//        PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
//        [query whereKey:kPAPTagActivityKey equalTo:self.contentObject];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (!error) {
//                for (CONTag *tag in objects) {
//                    NSString *linkDisplay = tag.text;
//                    NSString *linkUrl = tag.taggedObject.objectId;
//                    NSRange range = [self.contentLabel.text rangeOfString:linkDisplay];
//                    [self.contentLabel addLinkToURL:[NSURL URLWithString:linkUrl] withRange:range];
//                }
//            }
//        }];
//    }
    
    // Set mentions
    if (self.contentObject) {
        PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [query whereKey:kPAPActivityCommentKey equalTo:self.contentObject];
//        [query includeKey:kPAPActivityToUserKey];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSString *content = self.contentLabel.text;
                NSMutableArray *linkDisplayArray = [[NSMutableArray alloc] init];
                for (PFObject *mention in objects) {
                    NSString *linkDisplay = [mention objectForKey:kPAPActivityContentKey];
                    if ([linkDisplayArray containsObject:linkDisplay]) {
                        continue;
                    }
                    [linkDisplayArray addObject:linkDisplay];
                    PFUser *mentionedUser = [mention objectForKey:kPAPActivityToUserKey];
                    NSString *linkUrl = [mentionedUser objectId];
                    NSArray *rangeValues = [self rangesOfString:linkDisplay inString:content];
                    for (NSValue *rangeValue in rangeValues) {
                        NSRange range = [rangeValue rangeValue];
                        [self.contentLabel addLinkToURL:[NSURL URLWithString:linkUrl] withRange:range];
                    }
                }
            }
        }];
    }
    
    [self setNeedsDisplay];
}

- (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    NSMutableArray *results = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    while ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        [results addObject:[NSValue valueWithRange:range]];
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    return results;
}

- (void)setDate:(NSDate *)date {
    // Set the label with a human readable time
    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date]];
    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    // Change the mainView's frame to be insetted by insetWidth and update the content text space
    cellInsetWidth = insetWidth;
    [mainView setFrame:CGRectMake(insetWidth, mainView.frame.origin.y, mainView.frame.size.width-2*insetWidth, mainView.frame.size.height)];
    horizontalTextSpace = [PAPBaseTextCell horizontalTextSpaceForInsetWidth:insetWidth];
    [self setNeedsDisplay];
}

/* Since we remove the compile-time check for the delegate conforming to the protocol
 in order to allow inheritance, we add run-time checks. */
- (id<PAPBaseTextCellDelegate>)delegate {
    return (id<PAPBaseTextCellDelegate>)delegate;
}

- (void)setDelegate:(id<PAPBaseTextCellDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

- (void)hideSeparator:(BOOL)hide {
    hideSeparator = hide;
}

@end
