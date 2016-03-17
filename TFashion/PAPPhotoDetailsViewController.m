
#import "PAPPhotoDetailsViewController.h"
#import "PAPActivityCell.h"
#import "PAPAccountViewController.h"
#import "PAPLoadMoreCell.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

enum ActionSheetTags {
    MainActionSheetTag = 0,
    ConfirmDeleteActionSheetTag = 1
};

@interface PAPPhotoDetailsViewController ()
@property (nonatomic, strong) PAPPhotoDetailsHeaderView *headerView;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@property (nonatomic, strong) NSMutableArray *mentionResults;
@property (nonatomic, strong) NSMutableArray *mentionLinkArray;

@property (nonatomic, strong) CONCommentTextView *commentTextView;
@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UIButton *sendButton;

@end

static const CGFloat kPAPCellInsetWidth = 0.0f;

@implementation PAPPhotoDetailsViewController
@synthesize photo, headerView, cloth;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserLikedUnlikedClothCallbackFinishedNotification object:self.cloth];
}

- (id)initWithPhoto:(PFObject *)aPhoto cloth:(PFObject *)aCloth {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;

        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of comments to show per page
        self.objectsPerPage = 30;

        self.loadingViewEnabled = NO;
        
        self.photo = aPhoto;
        self.cloth = aCloth;
        
        self.likersQueryInProgress = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
    
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    self.navigationItem.title = @"";

    // Set table view properties
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = texturedBackgroundView;

    // Set table header
    self.headerView = [[PAPPhotoDetailsHeaderView alloc] initWithFrame:[PAPPhotoDetailsHeaderView rectForView] photo:self.photo cloth:self.cloth];
    self.headerView.delegate = self;
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Set input bar
    _inputBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.navigationController.view.frame) - CGRectGetHeight(self.tabBarController.tabBar.frame) - 40, 320.0f, 40.0f)];
    _inputBar.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    _inputBar.layer.borderWidth = 0.5;
    _inputBar.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    
    // Bring input bar to view from bottom with animation
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    [_inputBar.layer addAnimation:transition forKey:nil];
    [self.navigationController.view addSubview:_inputBar];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length + CGRectGetHeight(_inputBar.frame), 0);
    
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
    
    // Set action button as a navigation bar button item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(activityButtonAction:)];

    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedCloth:) name:PAPUtilityUserLikedUnlikedClothCallbackFinishedNotification object:self.cloth];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this photo
    BOOL hasCachedLikers = [[PAPCache sharedCache] attributesForCloth:self.cloth] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![self.navigationController.view.subviews containsObject:_inputBar]) {
        [self.navigationController.view addSubview:_inputBar];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_inputBar removeFromSuperview];
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

- (void)sendButtonAction:(id)sender
{
    NSString *trimmedComment = [_commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.photo objectForKey:kPAPPhotoUserKey]) {
        PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
        [comment setObject:trimmedComment forKey:kPAPActivityContentKey]; // Set comment text
        [comment setObject:[self.photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey]; // Set toUser
        [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
        [comment setObject:self.cloth forKey:kPAPActivityClothKey]; // Set fromUser
        [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
        [comment setObject:self.photo forKey:kPAPActivityPhotoKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kPAPPhotoUserKey]];
        comment.ACL = ACL;
        
        [[PAPCache sharedCache] incrementCommentCountForCloth:self.cloth];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": comment} repeats:NO];
        
        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && error.code == kPFErrorObjectNotFound) {
                [[PAPCache sharedCache] decrementCommentCountForCloth:self.cloth];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not post comment", nil) message:NSLocalizedString(@"This photo is no longer available", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserCommentedOnClothNotification object:self.cloth userInfo:@{@"comments": @(self.objects.count + 1)}];
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
            
            for (PFObject *mention in self.mentionLinkArray) {
                [mention setObject:comment forKey:kPAPActivityCommentKey];
                [mention saveEventually];
            }
            [self.mentionLinkArray removeAllObjects];
            
            //        for (CONTag *tag in self.mentionLinkArray) {
            //            tag.activity = comment;
            //            [tag saveEventually];
            //        }
        }];
    }
    
    [_commentTextView setText:@""];
    [_commentTextView resignFirstResponder];
}

#pragma mark - <CONCommentTextViewDelegate>

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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if (object) {
            NSString *commentString = [self.objects[indexPath.row] objectForKey:kPAPActivityContentKey];
            
            PFUser *commentAuthor = (PFUser *)[object objectForKey:kPAPActivityFromUserKey];
            
            NSString *nameString = @"";
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:kPAPUserDisplayNameKey];
            }
            
            return [PAPActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
        }
    }
    
    // The pagination row
    return 44.0f;
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [query whereKey:kPAPActivityClothKey equalTo:self.cloth];
    [query includeKey:kPAPActivityFromUserKey];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    [query orderByAscending:@"createdAt"]; 

    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    [self.headerView reloadLikeBar];
    [self loadLikers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"CommentCell";

    // Try to dequeue a cell and create one if necessary
    PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.delegate = self;
        cell.contentLabel.delegate = self;
        cell.contentLabel.userInteractionEnabled = YES;
    }
    
    [cell setUser:[object objectForKey:kPAPActivityFromUserKey]];
    [cell setContentObject:object];
    [cell setContentText:[object objectForKey:kPAPActivityContentKey]];
    [cell setDate:[object createdAt]];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPageDetails";

    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            // prompt to delete
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this photo?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Yes, delete photo", nil) otherButtonTitles:nil];
            actionSheet.tag = ConfirmDeleteActionSheetTag;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [self activityButtonAction:actionSheet];
        }
    } else if (actionSheet.tag == ConfirmDeleteActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            [self shouldDeletePhoto];
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_commentTextView resignFirstResponder];
}

#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self shouldPresentAccountViewForUser:aUser];
}


#pragma mark - PAPPhotoDetailsHeaderViewDelegate

-(void)photoDetailsHeaderView:(PAPPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

- (void)actionButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = MainActionSheetTag;
    actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete Photo", nil)];
    if (NSClassFromString(@"UIActivityViewController")) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Share Photo", nil)];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)activityButtonAction:(id)sender {
    if ([[self.photo objectForKey:kPAPPhotoPictureKey] isDataAvailable]) {
        [self showShareSheet];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[self.photo objectForKey:kPAPPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                [self showShareSheet];
            }
        }];
    }
}


#pragma mark - ()

- (void)showShareSheet {
    [[self.photo objectForKey:kPAPPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
                        
            // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
            if ([[[PFUser currentUser] objectId] isEqualToString:[[self.photo objectForKey:kPAPPhotoUserKey] objectId]] && [self.objects count] > 0) {
                PFObject *firstActivity = self.objects[0];
                if ([[[firstActivity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[self.photo objectForKey:kPAPPhotoUserKey] objectId]]) {
                    NSString *commentString = [firstActivity objectForKey:kPAPActivityContentKey];
                    [activityItems addObject:commentString];
                }
            }
            
            [activityItems addObject:[UIImage imageWithData:data]];
            [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://tfashion.parseapp.com/#pic/%@", self.photo.objectId]]];
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        }
    }];
}

- (void)handleCommentTimeout:(NSTimer *)aTimer {
    PFObject *comment = [[aTimer userInfo] valueForKey:@"comment"];
    for (PFObject *mention in self.mentionLinkArray) {
        [mention setObject:comment forKey:kPAPActivityCommentKey];
        [mention saveEventually];
    }
    [self.mentionLinkArray removeAllObjects];
    
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Comment", nil) message:NSLocalizedString(@"Your comment will be posted next time there is an Internet connection.", nil)  delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
    [alert show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userLikedOrUnlikedCloth:(NSNotification *)note {
    [self.headerView reloadLikeBar];
}

- (void)keyboardWillShow:(NSNotification*)note {
    
    CGRect keyboardBeginFrame, keyboardEndFrame;
    
    // position of keyboard before animation
    [[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBeginFrame];
    // and after..
    [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    CGFloat keyboardHeight = CGRectGetHeight(keyboardBeginFrame);
    
//    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height-keyboardHeight-CGRectGetHeight(_inputBar.frame)) animated:YES];
    
    CGPoint tableViewContentOffset = self.tableView.contentOffset;
    
    // Align the bottom edge of the photo with the keyboard
    tableViewContentOffset.y = self.tableView.contentSize.height-keyboardHeight-CGRectGetHeight(_inputBar.frame);
    
    // Set comment text view popover frame
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    CGFloat navBarBottom = CGRectGetMaxY(navBarFrame);
    CGFloat tableCellWidth = self.tableView.frame.size.width-2*kPAPCellInsetWidth;
    [_commentTextView setPopoverSize:CGRectMake(kPAPCellInsetWidth, tableViewContentOffset.y+navBarBottom, tableCellWidth, self.tableView.contentSize.height+navBarBottom+CGRectGetHeight(navBarFrame))];
    
    
    double animationDuration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int animationCurve = [[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // slide view up..
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    CGRect inputBarFrame = _inputBar.frame;
    inputBarFrame.origin.y -= (keyboardHeight - CGRectGetHeight(self.tabBarController.tabBar.frame));
    _inputBar.frame = inputBarFrame;
    [self.tableView setContentOffset:CGPointMake(0.0f, tableViewContentOffset.y)];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGFloat keyboardHeight = [[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    double animationDuration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int animationCurve = [[[note userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // slide view down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    CGRect inputBarFrame = _inputBar.frame;
    inputBarFrame.origin.y += (keyboardHeight - CGRectGetHeight(self.tabBarController.tabBar.frame));
    _inputBar.frame = inputBarFrame;
    [UIView commitAnimations];
}

- (void)loadLikers {
    if (self.likersQueryInProgress) {
        return;
    }

    self.likersQueryInProgress = YES;
    PFQuery *query = [PAPUtility queryForActivitiesOnCloth:cloth cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
            [self.headerView reloadLikeBar];
            return;
        }
        
        NSMutableArray *likers = [NSMutableArray array];
        NSMutableArray *commenters = [NSMutableArray array];
        
        BOOL isLikedByCurrentUser = NO;
        
        for (PFObject *activity in objects) {
            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            }
            
            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                    isLikedByCurrentUser = YES;
                }
            }
        }

        [[PAPCache sharedCache] setAttributesForCloth:cloth likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        [self.headerView reloadLikeBar];
    }];
}

- (BOOL)currentUserOwnsPhoto {
    return [[[self.photo objectForKey:kPAPPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]];
}

- (void)shouldDeletePhoto {
    // Delete all activites related to this photo
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityPhotoKey equalTo:self.photo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteEventually];
            }
        }
        
        // Delete photo
        [self.photo deleteEventually];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.photo objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
