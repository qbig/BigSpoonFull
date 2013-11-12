//
//  itemsOrderedTableViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 29/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ItemsOrderedViewController.h"
#define kOFFSET_FOR_KEYBOARD 80.0

@interface ItemsOrderedViewController (){
    int viewAppearCount;
    double GSTRate;
    double serviceChargeRate;
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
    
    self.scrollView.contentSize =CGSizeMake(ITEM_LIST_SCROLL_WIDTH, ITEM_LIST_SCROLL_HEIGHT);

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
    
    [self updatePriceLabels];
    [self updateTableHeight];
    
    return;
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keybaord Events

-(void)keyboardWillShow {
    
    NSLog(@"will show: self.view.frame.origin.y: %f", self.view.frame.origin.y);

    // Animate the current view out of the way
    if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    
    NSLog(@"will hide: self.view.frame.origin.y: %f", self.view.frame.origin.y);


    if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:NO];
    }
}
- (IBAction)textFieldDidBeginEditing:(id)sender {
    if ([sender isEqual:self.addNotesTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
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
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", dish.price];
        cell.quantityLabel.text = [NSString stringWithFormat:@"%d", [self.currentOrder getQuantityOfDishByDish:dish]];
        
        cell.plusButton.tag = dish.ID;
        cell.minusButton.tag = dish.ID;
        
        
        return cell;
    } else if ([tableView isEqual:self.pastOrderTableView]){
        PastOrderCell *cell = (PastOrderCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"PastOrderCell"];
        
        Dish *dish = [self.pastOrder.dishes objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = dish.name;
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", dish.price];
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

#pragma mark - Button event listeners

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

- (void) setGSTRate: (double) g andServiceChargeRate: (double) s{
    GSTRate = g;
    serviceChargeRate = s;
}


// This function is called when segue from menu list to here is performed
- (void)reloadOrderTablesWithCurrentOrder:(Order*) currentOrder andPastOrder:(Order*) pastOrder{
    self.currentOrder = currentOrder;
    self.pastOrder = pastOrder;
    [self.currentOrderTableView reloadData];
    [self.pastOrderTableView reloadData];
    [self updatePriceLabels];
    [self updateTableHeight];
}

- (IBAction)textFinishEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void) updatePriceLabels{
    [self updatePriceLabelsWithCurrentORder:self.currentOrder
                              SubtotalLabel:self.currentSubtotalLabel
                         ServiceChargeLabel:self.currentServiceChargeLabel
                    ServiceChargeTitleLabel:self.currentServiceChargeTitleLabel
                                   GSTLabel:self.currentGSTLabel
                              GSTTitleLabel:self.currentGSTTitleLabel
                              andTotalLabel:self.currentTotalLabel];
    
    [self updatePriceLabelsWithCurrentORder:self.pastOrder
                              SubtotalLabel:self.pastSubtotalLabel
                         ServiceChargeLabel:self.pastServiceChargeLabel
                    ServiceChargeTitleLabel:self.pastServiceChargeTitleLabel
                                   GSTLabel:self.pastGSTLabel
                              GSTTitleLabel:self.pastGSTTitleLabel
                              andTotalLabel:self.pastTotalLabel];
}

- (void) updatePriceLabelsWithCurrentORder: (Order *) newOrder
                          SubtotalLabel: (UILabel *) subTotalLabel
                        ServiceChargeLabel: (UILabel *) serviceChargeLabel
                   ServiceChargeTitleLabel: (UILabel *) serviceChargeTitleLabel
                                  GSTLabel: (UILabel *) GSTLabel
                             GSTTitleLabel: (UILabel *) GSTTitleLabel
                             andTotalLabel: (UILabel *) totalLabel{
    
    
    float subTotal = [newOrder getTotalPrice];
    subTotalLabel.text = [NSString stringWithFormat:@"$%.2f", subTotal];
    
    float serviceCharge = subTotal * serviceChargeRate;
    serviceChargeTitleLabel.text = [NSString stringWithFormat:@"Service Charge (%.0f%%):", serviceChargeRate * 100];
    serviceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", serviceChargeRate];
 
    float GST = subTotal * GSTRate;
    GSTTitleLabel.text = [NSString stringWithFormat:@"GST (%.0f%%):", GSTRate * 100];
    GSTLabel.text = [NSString stringWithFormat:@"$%.2f", GSTRate];
    
    float total = subTotal + serviceCharge + GST;
    totalLabel.text = [NSString stringWithFormat:@"$%.2f", total];
}

/*
 * The table height is dynamic.
 */
- (void) updateTableHeight{
    int currentOrderTableHeight = ITEM_LIST_TABLE_ROW_HEIGHT * [self.currentOrder getNumberOfKindsOfDishes];
    int pastOrderTableHeight = ITEM_LIST_TABLE_ROW_HEIGHT * [self.pastOrder getNumberOfKindsOfDishes];
    
    CGRect currentOrderFrame = self.currentOrderTableView.frame;
    [self.currentOrderTableView setFrame: CGRectMake(currentOrderFrame.origin.x,
                                                     currentOrderFrame.origin.y,
                                                     currentOrderFrame.size.width,
                                                     currentOrderTableHeight)];
    
    CGRect pasrOrderFrame = self.pastOrderTableView.frame;
    [self.pastOrderTableView setFrame:CGRectMake(pasrOrderFrame.origin.x,
                                                 pasrOrderFrame.origin.y,
                                                 pasrOrderFrame.size.width,
                                                 pastOrderTableHeight)];
    
    CGRect viewAfterframe = self.viewContainerForAfterCurrentOrderTable.frame;
    [self.viewContainerForAfterCurrentOrderTable setFrame:CGRectMake(viewAfterframe.origin.x,
                                                                     currentOrderFrame.origin.y + currentOrderTableHeight,
                                                                     viewAfterframe.size.width,
                                                                     viewAfterframe.size.height)];
    
    viewAfterframe = self.viewContainerForAfterPastOrderTable.frame;
    [self.viewContainerForAfterPastOrderTable setFrame:CGRectMake(viewAfterframe.origin.x,
                                                                  pasrOrderFrame.origin.y + pastOrderTableHeight,
                                                                  viewAfterframe.size.width,
                                                                  viewAfterframe.size.height)];
}


@end
