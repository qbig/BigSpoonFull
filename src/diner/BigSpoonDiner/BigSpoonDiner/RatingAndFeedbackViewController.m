//
//  RatingAndFeedbackViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RatingAndFeedbackViewController.h"

@interface RatingAndFeedbackViewController ()

@end

@implementation RatingAndFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"RatingAndFeedbackView" owner:self options:nil];
    self.view = [subviewArray objectAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    [self.currentOrder getNumberOfKindsOfDishes];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RatingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OutletCell"];
    Dish *dish = [[self.currentOrder dishes] objectAtIndex:indexPath.row];
    
    cell.dishNameLabel.text = dish.name;
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

# pragma mark - Event listeners

- (IBAction)ratingSubmitButtonPressed:(id)sender{
    
    [self ratingCancelButtonPressed:sender];
}

- (IBAction)ratingCancelButtonPressed:(id)sender{
    
    [self fadeOut];
}


- (IBAction)textFieldDidEndOnExit:(id)sender {

    [self fadeOut];
}

- (void) fadeOut{
    // Perform the fade-out animation first. Then remove the view.
    [BigSpoonAnimationController animateTransitionOfUIView:self.view willShow:NO];
    [self performSelector:@selector(removeSelfFromParent) withObject:nil afterDelay:REQUEST_CONTROL_PANEL_TRANSITION_DURATION];
}

- (void) removeSelfFromParent{
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void) reloadDataWithOrder: (Order *) c{
    self.currentOrder = c;
    [self.ratingsTableView reloadData];
}


@end
