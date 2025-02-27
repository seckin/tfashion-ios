//
//  PAPHomeViewController.m
//  Anypic
//
//  Created by Héctor Ramos on 5/2/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPHomeViewController.h"
#import "PAPFindFriendsViewController.h"
#import "CONIntroViewController.h"

@interface PAPHomeViewController () <CONIntroViewControllerDelegate>
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation PAPHomeViewController
@synthesize firstLaunch;
@synthesize blankTimelineView;


#pragma mark - UIViewControllerb

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL didUserSeeIntro = [[[NSUserDefaults standardUserDefaults] valueForKey:kDidUserCompletedIntro] boolValue];
    if (!didUserSeeIntro) {
//        CONIntroViewController *introVC = [[CONIntroViewController alloc] init];
//        introVC.introViewControllerDelegate = self;
//        [self.parentViewController presentViewController:introVC animated:NO completion:nil];
    }
    
    self.navigationItem.title = @"Standout";
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];

    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *lightAttributes = @{NSForegroundColorAttributeName: [UIColor lightGrayColor] };
    NSDictionary *darkAttributes = @{ NSForegroundColorAttributeName: [UIColor darkGrayColor] };
    NSDictionary *underlineAttributes = @{ NSUnderlineStyleAttributeName: @1 };
    
    NSMutableAttributedString *buttonTitle = [[NSMutableAttributedString alloc] initWithString:@"You don't have any\n friends on Standout yet.\n\nSearch for people."];
    [buttonTitle setAttributes:underlineAttributes range:NSMakeRange(40, 20)];
    NSMutableAttributedString *buttonTitleHighlighted = [[NSMutableAttributedString alloc] initWithAttributedString:buttonTitle];
    [buttonTitle addAttributes:darkAttributes range:NSMakeRange(0, 60)];
    [buttonTitleHighlighted addAttributes:lightAttributes range:NSMakeRange(0, 60)];
    
    [button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    [button setAttributedTitle:buttonTitleHighlighted forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont fontWithName:@"Gotham-Medium" size:17.0f]];
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setNumberOfLines:0];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button setFrame:CGRectMake(24.0f, 133.0f, 271.0f, 140.0f)];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
}


#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    if (self.objects.count == 0) {
        self.tableView.scrollEnabled = NO;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }    
}

#pragma mark - <CONIntroViewControllerDelegate>

- (void)intoViewControllerDidDismiss:(CONIntroViewController *)introViewController
{
    PAPHomeViewController *homeviewcontroller = [[PAPHomeViewController alloc] init];
    [self.parentViewController presentViewController:homeviewcontroller animated:YES completion:nil];
}

#pragma mark - ()

- (void)inviteFriendsButtonAction:(id)sender {
    PAPFindFriendsViewController *detailViewController = [[PAPFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}
@end
