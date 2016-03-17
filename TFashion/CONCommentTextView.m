//
//  CONCommentTextView.m
//  TFashion
//
//  Created by Utku Sakil on 1/22/15.
//
//

#import "CONCommentTextView.h"
#import <Parse/PFFile.h>

@implementation CONCommentTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.isScrollable = NO;
        self.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        self.returnKeyType = UIReturnKeyDefault;
        self.keyboardType = UIKeyboardTypeTwitter;
        self.minNumberOfLines = 1;
        self.maxNumberOfLines = 6;
        self.font = [UIFont fontWithName:@"Gotham-Book" size:14.0f];
        self.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        self.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.backgroundColor = [UIColor whiteColor];
        self.placeholder = @"Add a comment";
        self.layer.cornerRadius = 5.0;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    }
    return self;
}

//Private declaration of UITableViewController that will present the results in a popover depending on the search query typed by the user.
UITableViewController *results;
UITableViewController *tableViewController;

//Private declaration of NSArray that will hold the data supplied by the user for showing results in search popover.
NSArray *data;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.text.length > 0 && self.isFirstResponder) {
        //User entered some text in the textfield. Check if the delegate has implemented the required method of the protocol. Create a popover and show it around the CONCommentTextView.
        
        if ([self.delegate respondsToSelector:@selector(dataForPopoverInTextView:)]) {
            data = [[self delegate] dataForPopoverInTextView:self];
            [self provideSuggestions];
        }
        else{
            NSLog(@"<CONCommentTextView> WARNING: You have not implemented the requred methods of the CONCommentTextView protocol.");
        }
    }
    else{
        //No text entered in the textfield. If -textFieldShouldSelect is YES, select the first row from results using -handleExit method.tableView and set the displayText on the text field. Check if suggestions view is visible and dismiss it.
        if ([tableViewController.tableView superview] != nil) {
            [tableViewController.tableView removeFromSuperview];
        }
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (self.text.length > 0 && self.isFirstResponder) {
        //User entered some text in the textfield. Check if the delegate has implemented the required method of the protocol. Create a popover and show it around the CONCommentTextView.
        
        if ([self.delegate respondsToSelector:@selector(dataForPopoverInTextView:)]) {
            data = [[self delegate] dataForPopoverInTextView:self];
            [self provideSuggestions];
        }
        else{
            NSLog(@"<CONCommentTextView> WARNING: You have not implemented the requred methods of the CONCommentTextView protocol.");
        }
    }
    else{
        //No text entered in the textfield. If -textFieldShouldSelect is YES, select the first row from results using -handleExit method.tableView and set the displayText on the text field. Check if suggestions view is visible and dismiss it.
        if ([tableViewController.tableView superview] != nil) {
            [tableViewController.tableView removeFromSuperview];
        }
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([tableViewController.tableView superview] != nil) {
        [tableViewController.tableView removeFromSuperview];
    }
    return YES;
}

//This method checks if a selection needs to be made from the suggestions box using the delegate method -textFieldShouldSelect. If a user doesn't tap any search suggestion, the textfield automatically selects the top result. If there is no result available and the delegate method is set to return YES, the textfield will wrap the entered the text in a NSDictionary and send it back to the delegate with 'CustomObject' key set to 'NEW'
- (void)handleExit
{
    [tableViewController.tableView removeFromSuperview];
    if ([[self delegate] respondsToSelector:@selector(textViewShouldSelect:)]) {
        if ([[self delegate] textViewShouldSelect:self]) {
            if ([self applyFilterWithSearchQuery:self.text].count > 0) {
                self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0] objectForKey:@"DisplayText"];
                if ([[self delegate] respondsToSelector:@selector(textView:didEndEditingWithSelection:)]) {
                    [[self delegate] textView:self didEndEditingWithSelection:[[self applyFilterWithSearchQuery:self.result] objectAtIndex:0]];
                }
                else{
                    NSLog(@"<CONCommentTextView> WARNING: You have not implemented a method from CONCommentTextViewDelegate that is called back when the user selects a search suggestion.");
                }
            }
            else if (self.text.length > 0){
                //Make sure that delegate method is not called if no text is present in the text field.
                if ([[self delegate] respondsToSelector:@selector(textView:didEndEditingWithSelection:)]) {
                    [[self delegate] textView:self didEndEditingWithSelection:[NSDictionary dictionaryWithObjectsAndKeys:self.result,@"DisplayText",self.resultObject,@"CustomObject", nil]];
                }
                else{
                    NSLog(@"<CONCommentTextView> WARNING: You have not implemented a method from CONCommentTextViewDelegate that is called back when the user selects a search suggestion.");
                }
            }
        }
    }
}


#pragma mark UITableView DataSource & Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [[self applyFilterWithSearchQuery:self.text] count];
    if (count == 0) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [tableViewController.tableView setAlpha:0.0];
                         }
                         completion:^(BOOL finished){
                             [tableViewController.tableView removeFromSuperview];
                             tableViewController = nil;
                         }];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CONResultsCell";
    NSDictionary *dataForRowAtIndexPath = [[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row];
    PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = 0;
        cell.delegate = self;
    }
    
    PFUser *user = (PFUser *)[dataForRowAtIndexPath objectForKey:@"CustomObject"];
    [cell setUser:user];
    
    UILabel *usernameLabel = [[UILabel alloc] init];
    usernameLabel.font = cell.timeLabel.font;
    usernameLabel.textColor = cell.timeLabel.textColor;
    usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
    [usernameLabel sizeToFit];
    CGRect frame = usernameLabel.frame;
    frame.origin = CGPointMake(45, 35);
    usernameLabel.frame = frame;
    [cell addSubview:usernameLabel];
    
    return cell;
}

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self.text componentsSeparatedByCharactersInSet:charSet]];
    [components removeObject:components.lastObject];
    
    self.result = [NSString stringWithFormat:@"@%@",[aUser username]];
    self.resultObject = aUser;
    [components addObject:self.result];
    self.text = [components componentsJoinedByString:@" "];
    [self handleExit];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self.text componentsSeparatedByCharactersInSet:charSet]];
    [components removeObject:components.lastObject];
    
    PFUser *aUser = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row] objectForKey:@"CustomObject"];
    self.result = [NSString stringWithFormat:@"@%@",[aUser username]];
    self.resultObject = aUser;
    [components addObject:self.result];
    self.text = [components componentsJoinedByString:@" "];
    [self handleExit];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#pragma mark Filter Method

- (NSArray *)applyFilterWithSearchQuery:(NSString *)filter
{
    
    //MARK: Changed to recognize mentions
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *components = [filter componentsSeparatedByCharactersInSet:charSet];
    NSString *lastWord = components.lastObject;
    if (lastWord.length > 0) {
        NSString *firstLetter = [lastWord substringToIndex:1];
        if ([firstLetter isEqualToString:@"@"]) {
            filter = [lastWord substringFromIndex:1];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DisplayText BEGINSWITH[cd] %@", filter];
            NSArray *filteredGoods = [NSArray arrayWithArray:[data filteredArrayUsingPredicate:predicate]];
            return filteredGoods;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
    
}

#pragma mark Popover Method(s)

- (void)provideSuggestions
{
    //Providing suggestions
    if (tableViewController.tableView.superview == nil && [[self applyFilterWithSearchQuery:self.text] count] > 0) {
        tableViewController = [[UITableViewController alloc] init];
        [tableViewController.tableView setDelegate:self];
        [tableViewController.tableView setDataSource:self];
        if (self.backgroundColor == nil) {
            //Background color has not been set by the user. Use default color instead.
            [tableViewController.tableView setBackgroundColor:[UIColor whiteColor]];
        }
        else{
            [tableViewController.tableView setBackgroundColor:self.backgroundColor];
        }
        
        [tableViewController.tableView setSeparatorColor:self.seperatorColor];
        if (self.popoverSize.size.height == 0.0) {
            //PopoverSize frame has not been set. Use default parameters instead.
            CGRect frameForPresentation = [self frame];
            frameForPresentation.origin.y += self.frame.size.height;
            frameForPresentation.size.height = 200;
            [tableViewController.tableView setFrame:frameForPresentation];
        }
        else{
            [tableViewController.tableView setFrame:self.popoverSize];
        }
        [self.presentingView addSubview:tableViewController.tableView];
        tableViewController.tableView.alpha = 0.0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             [tableViewController.tableView setAlpha:1.0];
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        
    }
    else{
        [tableViewController.tableView reloadData];
    }
}

@end
