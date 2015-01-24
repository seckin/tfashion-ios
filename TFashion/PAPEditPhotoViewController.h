//
//  PAPEditPhotoViewController.h
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "CONCommentTextView.h"

@interface PAPEditPhotoViewController : UIViewController <UIScrollViewDelegate, CONCommentTextViewDelegate>

- (id)initWithImage:(UIImage *)aImage;

@end
