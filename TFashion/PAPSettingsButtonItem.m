//
//  PAPSettingsButtonItem.m
//  Anypic
//
//  Created by Héctor Ramos on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPSettingsButtonItem.h"
//#import "UIColor+CreateMethods.h"

@implementation PAPSettingsButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self = [super initWithCustomView:settingsButton];
    if (self) {
        FAKIonIcons *settingsIcon = [FAKIonIcons iosGearIconWithSize:27];
        [settingsIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        
        [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 27.0f, 27.0f)];
        [settingsButton setImage:[settingsIcon imageWithSize:CGSizeMake(27, 27)] forState:UIControlStateNormal];
    }
    
    return self;
}
@end
