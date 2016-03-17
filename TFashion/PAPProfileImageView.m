//
//  PAPProfileImageView.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/17/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPProfileImageView.h"
#import "ParseUI/ParseUI.h"
#import "UIImageView+WebCache.h"

@interface PAPProfileImageView ()

@end

@implementation PAPProfileImageView

@synthesize profileImageView;
@synthesize profileButton;


#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.profileImageView = [[PFImageView alloc] initWithFrame:frame];
        [self addSubview:self.profileImageView];
        
        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.profileButton];
        
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];

    self.profileImageView.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}


#pragma mark - PAPProfileImageView

- (void)setFile:(PFFile *)file {
    if (!file) {
        return;
    }

    self.profileImageView.image = [UIImage imageNamed:@"AvatarPlaceholder.png"];
    self.profileImageView.file = file;
//    NSString *substring = [file.url substringFromIndex:7];
//    NSString *prefix = @"https://s3.amazonaws.com/";
//    NSString *updatedImageUrl = [prefix stringByAppendingString:substring];
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.profileImageView.file.url] placeholderImage:[UIImage imageNamed:@"AvatarPlaceholder.png"]];
//    NSLog(@"updatedprofile image url: %@", updatedImageUrl);
    [self.profileImageView loadInBackground];
}

- (void)setImage:(UIImage *)image {
    self.profileImageView.image = image;
}

@end
