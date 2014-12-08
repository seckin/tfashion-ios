//
//  PAPPhotoDetailsFooterView.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/16/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MPGTextField.h"

@interface PAPPhotoDetailsFooterView : UIView

@property (nonatomic, strong) MPGTextField *commentField;
@property (nonatomic) BOOL hideDropShadow;

+ (CGRect)rectForView;

@end
