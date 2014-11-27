//
//  PAPSettingsButtonItem.m
//  Anypic
//
//  Created by Héctor Ramos on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPSettingsButtonItem.h"

@implementation PAPSettingsButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self = [super initWithCustomView:settingsButton];
    if (self) {
        FAKIonIcons *settingsIcon = [FAKIonIcons ios7GearIconWithSize:28];
        [settingsIcon addAttribute:NSForegroundColorAttributeName value:[UIColor
                                                                     whiteColor]];
        
        [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
        [settingsButton setImage:[settingsIcon imageWithSize:CGSizeMake(28, 28)] forState:UIControlStateNormal];
    }
    
    return self;
}
@end
