//
//  PAPEditPhotoViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPEditPhotoViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "AppDelegate.h"
#import "CONTag.h"

@interface PAPEditPhotoViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CONCommentTextView *commentTextView;
@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, strong) NSMutableArray *mentionResults;
@property (nonatomic, strong) NSMutableArray *mentionLinkArray;
@property (nonatomic, assign) CGFloat inputBarPositionDiffWhenKeyboardOn;

@end

@implementation PAPEditPhotoViewController
@synthesize scrollView;
@synthesize image;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"Memory warning on Edit");
}


#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;

    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 42.0f, 320.0f, 320.0f)];
    [photoImageView setBackgroundColor:[UIColor whiteColor]];
    [photoImageView setImage:self.image];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.scrollView addSubview:photoImageView];
    
    // Set input bar
    _inputBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.scrollView.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame) - 40, 320.0f, 40.0f)];
    _inputBar.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    _inputBar.layer.borderWidth = 0.5;
    _inputBar.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    [self.scrollView addSubview:_inputBar];
    
    // Set comment text view
    _commentTextView = [[CONCommentTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    _commentTextView.delegate = self;
    _commentTextView.presentingView = self.view;
    [_inputBar addSubview:_commentTextView];
    
    // Set send button
    _sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _sendButton.frame = CGRectMake(_inputBar.frame.size.width - 69, 8, 63, 27);
    _sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [_sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.enabled = NO;
    [_inputBar addSubview:_sendButton];

    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y + photoImageView.frame.size.height + _inputBar.frame.size.height)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self shouldUploadImage:self.image];
    
    // Generate mention data
    // Find users who are followed by current user
    PFQuery *followingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [followingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingQuery includeKey:kPAPActivityToUserKey];
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects) {
            NSMutableArray *followees = [[NSMutableArray alloc] init];
            for (PFObject *followActivity in objects) {
                PFUser *followee = [followActivity objectForKey:kPAPActivityToUserKey];
                [followees addObject:followee];
            }
            [self generateMentionData:followees];
        }
    }];
    
    self.mentionLinkArray = [[NSMutableArray alloc] init];
}

#pragma mark - Private

- (void)generateMentionData:(NSArray *)contents
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        //
        //
        self.mentionResults = [[NSMutableArray alloc] init];
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.mentionResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:[obj objectForKey:kPAPUserDisplayNameKey], @"DisplayText",obj,@"CustomObject", nil]];
            }];
        });
    });
}

#pragma mark <CONCommentTextViewDelegate>

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect inputBarFrame = _inputBar.frame;
    inputBarFrame.size.height -= diff;
    inputBarFrame.origin.y += diff;
    _inputBar.frame = inputBarFrame;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if (growingTextView.text.length > 0) {
        _sendButton.enabled = YES;
    } else {
        _sendButton.enabled = NO;
    }
}

- (NSArray *)dataForPopoverInTextView:(CONCommentTextView *)textView
{
    if ([textView isEqual:_commentTextView]) {
        return self.mentionResults;
    } else {
        return nil;
    }
}

- (BOOL)textViewShouldSelect:(CONCommentTextView *)textView
{
    return YES;
}

- (void)textView:(CONCommentTextView *)textView didEndEditingWithSelection:(NSDictionary *)result
{
    if ([textView isEqual:_commentTextView]) {
        //        CONTag *tag = [CONTag object];
        //        tag.text = [result valueForKey:@"DisplayText"];
        //        PFUser *user = [result valueForKey:@"CustomObject"];
        //        tag.taggedObject = user;
        //        tag.type = kPAPTagTypeMention; //TODO: Change when hashtag is active
        //        [self.mentionLinkArray addObject:tag];
        NSString *text = [result valueForKey:@"DisplayText"];
        PFUser *mentionedUser = [result valueForKey:@"CustomObject"];
        PFObject *mention = [PFObject objectWithClassName:kPAPActivityClassKey];
        [mention setObject:text forKey:kPAPActivityContentKey]; // Set mention text
        [mention setObject:mentionedUser forKey:kPAPActivityToUserKey]; // Set toUser
        [mention setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
        [mention setObject:kPAPActivityTypeMention forKey:kPAPActivityTypeKey];
        [self.mentionLinkArray addObject:mention];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentTextView resignFirstResponder];
}

#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    UIImage *resizedImage = [anImage resizeImageScaledToSize:CGSizeMake(560.0f, 560.0f)];
    UIImage *thumbnailImage = [anImage resizeImageScaledToSize:CGSizeMake(86.0f, 86.0f)];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];

    NSLog(@"Requested background expiration task with id %lu for Anypic photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Thumbnail uploaded successfully");
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    
    CGFloat navBarBottom = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height + navBarBottom;
    
    // Set comment text field popover frame
    [_commentTextView setPopoverSize:CGRectMake(0, scrollViewContentOffset.y + navBarBottom, 320,([UIScreen mainScreen].bounds.size.height-keyboardFrameEnd.size.height-navBarBottom-CGRectGetHeight(_inputBar.frame)))];
    
    double animationDuration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int animationCurve = [[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // slide view up..
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    CGRect inputBarFrame = _inputBar.frame;
    _inputBarPositionDiffWhenKeyboardOn = CGRectGetMinY(keyboardFrameEnd)+CGRectGetHeight(_inputBar.frame)-inputBarFrame.origin.y;
    inputBarFrame.origin.y += _inputBarPositionDiffWhenKeyboardOn;
    _inputBar.frame = inputBarFrame;
    [self.scrollView setContentOffset:scrollViewContentOffset];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    
    double animationDuration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int animationCurve = [[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // slide view down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    CGRect inputBarFrame = _inputBar.frame;
    inputBarFrame.origin.y -= _inputBarPositionDiffWhenKeyboardOn;
    _inputBar.frame = inputBarFrame;
    [self.scrollView setContentSize:scrollViewContentSize];
    [UIView commitAnimations];
}

- (void)sendButtonAction:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  trimmedComment,kPAPEditPhotoViewControllerUserInfoCommentKey,
                                  nil];
    }
    
    if (!self.photoFile || !self.thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:kPAPPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kPAPPhotoUserKey];
    [photo setObject:self.photoFile forKey:kPAPPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kPAPPhotoThumbnailKey];
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];

    // save
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded");

            [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                NSString *commentText = [userInfo objectForKey:kPAPEditPhotoViewControllerUserInfoCommentKey];
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
                    [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
                    [comment setObject:photo forKey:kPAPActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                    [comment setObject:commentText forKey:kPAPActivityContentKey];
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
//                    for (CONTag *tag in self.mentionLinkArray) {
//                        tag.activity = comment;
//                        [tag saveEventually];
//                    }
                    for (PFObject *mention in self.mentionLinkArray) {
                        [mention setObject:comment forKey:kPAPActivityCommentKey];
                        [mention saveEventually];
                    }
                    [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
                    
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
            }
        } else {
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    [_commentTextView resignFirstResponder];
}

- (void)cancelButtonAction:(id)sender {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}

@end
