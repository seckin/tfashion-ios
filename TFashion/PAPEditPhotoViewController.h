//
//  PAPEditPhotoViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MPGTextField.h"

@interface PAPEditPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, MPGTextFieldDelegate>

- (id)initWithImage:(UIImage *)aImage;

@end
