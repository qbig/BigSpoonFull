//
//  itemsOrderedTableViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 29/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ItemsOrderedViewController.h"

@interface ItemsOrderedViewController (){
    int viewAppearCount;
}

@end

@implementation ItemsOrderedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ItemsOrderedViewController Loading view");
    viewAppearCount = 0;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    viewAppearCount++;
    
    // If it's not first time load, the navigation bar item will automatically be added on top of the page
    // We don't want that.
    // So in the second appearence, bring up the tableview. It will stay this way ever after.
    if (viewAppearCount == -2){
        CGRect frame = self.scrollView.frame;
        self.scrollView.frame = CGRectMake(frame.origin.x, frame.origin.y - HEIGHT_NAVIGATION_ITEM, frame.size.width, frame.size.height);
        [self.view bringSubviewToFront:self.scrollView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.currentOrderTableView]) {
        return 1;
    } else if ([tableView isEqual:self.pastOrderTableView]){
        return 1;
    } else{
        NSLog(@"Unrecognized tableView is calling delegate method");
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([tableView isEqual:self.currentOrderTableView]) {
        return [self.currentOrder getNumberOfKindsOfDishes];
    } else if ([tableView isEqual:self.pastOrderTableView]){
        return [self.pastOrder getNumberOfKindsOfDishes];
    } else{
        NSLog(@"Unrecognized tableView is calling delegate method");
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.currentOrderTableView]) {
        NewOrderCell *cell = (NewOrderCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"NewOrderCell"];
        Dish *dish = [self.currentOrder.dishes objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = dish.name;
        cell.priceLabel.text = [NSString stringWithFormat:@"$%d", dish.price];
        cell.quantityLabel.text = [NSString stringWithFormat:@"%d", [self.currentOrder getQuantityOfDishByDish:dish]];
        
        cell.plusButton.tag = dish.ID;
        cell.minusButton.tag = dish.ID;
        
        
        return cell;
    } else if ([tableView isEqual:self.pastOrderTableView]){
        PastOrderCell *cell = (PastOrderCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"PastOrderCell"];
        
        Dish *dish = [self.pastOrder.dishes objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = dish.name;
        cell.priceLabel.text = [NSString stringWithFormat:@"$%d", dish.price];
        cell.quantityLabel.text = [NSString stringWithFormat:@"%d", [self.pastOrder getQuantityOfDishByDish:dish]];
       
        return cell;
    } else{
        NSLog(@"Unrecognized tableView is calling delegate method");
        return nil;
    }
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

- (IBAction)plusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {

    
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.currentOrderTableView];
    NSIndexPath * indexPath = [self.currentOrderTableView indexPathForRowAtPoint: location];
    
    int dishID = sender.tag;
    
    NSLog(@"Added dish at row: %d with ID: %d", indexPath.row, dishID);

    
    NewOrderCell *cell = (NewOrderCell *)[self.currentOrderTableView cellForRowAtIndexPath: indexPath];
    
    
    self.currentOrder = [self.delegate addDishWithID: dishID];
    cell.quantityLabel.text = [NSString stringWithFormat:@"%d", [self.currentOrder getQuantityOfDishByID:dishID]];

}

- (IBAction)minusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.currentOrderTableView];
    NSIndexPath * indexPath = [self.currentOrderTableView indexPathForRowAtPoint: location];
    
    int dishID = sender.tag;
    
    NSLog(@"Minus dish at row: %d with ID: %d", indexPath.row, dishID);
    
    NewOrderCell *cell = (NewOrderCell *)[self.currentOrderTableView cellForRowAtIndexPath: indexPath];
    
    
    self.currentOrder = [self.delegate minusDishWithID: dishID];
    cell.quantityLabel.text = [NSString stringWithFormat:@"%d", [self.currentOrder getQuantityOfDishByID:dishID]];

}
- (IBAction)placeOrderButtonPressed:(id)sender {
    
    [self.delegate placeOrderWithNotes:self.addNotesTextField.text];
    
    // Erase the existing text.
    self.addNotesTextField.text = @"";
    
    // Put away the keyboard
    [self.addNotesTextField resignFirstResponder];
    
}

- (void)reloadOrderTablesWithCurrentOrder:(Order*) currentOrder andPastOrder:(Order*) pastOrder{
    self.currentOrder = currentOrder;
    self.pastOrder = pastOrder;
    [self.currentOrderTableView reloadData];
    [self.pastOrderTableView reloadData];
}

- (IBAction)textFinishEditing:(id)sender {
    [sender resignFirstResponder];
}
@end
