//
//  CONProviderDetailViewController.m
//  TFashion
//
//  Created by Utku Sakil on 12/31/14.
//
//

#import "CONProviderDetailViewController.h"

@interface CONProviderDetailViewController () <UIAlertViewDelegate>

@end

@implementation CONProviderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.socialAccount.type capitalizedString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = @"Unlink";
    cell.textLabel.textColor = self.view.tintColor;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"ACCOUNT";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Connected as %@", self.socialAccount.providerDisplayName];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = [NSString stringWithFormat:@"Do you want to unlink your %@ account?", self.title];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, I am.", nil];
    [alert show];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"girdi");
        self.socialAccount.isActive = NO;
        [self.socialAccount saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self.navigationController popViewControllerAnimated:YES];
                [self.master.tableView reloadRowsAtIndexPaths:@[self.providerIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }
}

@end
