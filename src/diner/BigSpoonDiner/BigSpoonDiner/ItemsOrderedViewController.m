//
//  itemsOrderedTableViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 29/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ItemsOrderedViewController.h"

@interface ItemsOrderedViewController (){
    double GSTRate;
    double serviceChargeRate;
}
@property BOOL isAddingNotes;

@end

@implementation ItemsOrderedViewController
@synthesize addNotesButton;
@synthesize isAddingNotes;
@synthesize placeOrderButton;
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
    UITapGestureRecognizer * tapGestureToDismissKeyboard = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(dismissKeyboard)];
    self.isAddingNotes = NO;
    [self.view addGestureRecognizer:tapGestureToDismissKeyboard];

    //self.scrollView.contentSize =CGSizeMake(ITEM_LIST_SCROLL_WIDTH, ITEM_LIST_SCROLL_HEIGHT);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [TestFlight passCheckpoint:@"CheckPoint:User at Items Page"];
}


- (void) viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePriceLabels) name:NOTIF_ORDER_UPDATE object:nil];
    [super viewWillAppear:animated];
    self.userInfo = [User sharedInstance];
    [self updatePriceLabels];
    
    return;
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// This was for a fix of the bug
//- (void) viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    
//    [self.scrollView setContentOffset:CGPointZero animated:NO];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
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
        return [self.userInfo.currentOrder getNumberOfKindsOfDishes];
    } else if ([tableView isEqual:self.pastOrderTableView]){
        return [self.userInfo.pastOrder getNumberOfKindsOfDishes];
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
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(hideNote) name:HIDE_NOTE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(displayNote) name:SHOW_NOTE object:nil];
        Dish *dish = [self.userInfo.currentOrder.dishes objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = dish.name;
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.1f", dish.price];
        cell.quantityLabel.text = [NSString stringWithFormat:@"%d", [self.userInfo.currentOrder getQuantityOfDishByDish:dish]];
        
        cell.plusButton.tag = dish.ID;
        cell.minusButton.tag = dish.ID;
        if (self.isAddingNotes){
            cell.orderNote.hidden = NO;
        } else {
            cell.orderNote.hidden = YES;
        }
        return cell;
    } else if ([tableView isEqual:self.pastOrderTableView]){
        PastOrderCell *cell = (PastOrderCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"PastOrderCell"];
        
        Dish *dish = [self.userInfo.pastOrder.dishes objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = dish.name;
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.1f", dish.price];
        cell.quantityLabel.text = [NSString stringWithFormat:@"%d", [self.userInfo.pastOrder getQuantityOfDishByDish:dish]];
       
        return cell;
    } else{
        NSLog(@"Unrecognized tableView is calling delegate method");
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.currentOrderTableView]) {
        if (self.isAddingNotes){
            return ITEM_LIST_TABLE_ROW_HEIGHT_EXPANDED;
        } else {
            return ITEM_LIST_TABLE_ROW_HEIGHT;
        }
    } else if ([tableView isEqual:self.pastOrderTableView]){
        return ORDERED_ITEM_LIST_TABLE_ROW_HEIGHT;
    } else{
        NSLog(@"Unrecognized tableView is calling delegate method");
        return 1;
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
- (IBAction)addNotesButtonPressed:(id)sender {
    NSLog(@"Add notes btn pressed");
    if (self.isAddingNotes) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_NOTE object:nil];
        [self dismissKeyboard];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_NOTE object:nil];
    }
    self.isAddingNotes = !self.isAddingNotes;
    [self.currentOrderTableView beginUpdates];
    [self.currentOrderTableView endUpdates];
    // Update view point when the resulting state is "isAddingNotes"
    // Otherwise, do note update view point
    [self updateTablesAndScrollviewHeight: self.isAddingNotes];
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)sender {
    
    float offsetFromTopToContainerView = sender.superview.frame.origin.y;
    float offsetFromContainerViewToTextField = sender.frame.origin.y;
    float offsetScrollView = self.scrollView.contentOffset.y;
   
    float offsetFromTopToTextField = offsetFromTopToContainerView + offsetFromContainerViewToTextField - offsetScrollView;
    
    NSLog(@"%f %f %f", offsetFromTopToContainerView, offsetFromContainerViewToTextField, offsetScrollView);
    
    if ([sender isEqual:self.addNotesTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0 && offsetFromTopToTextField > OFFSET_FOR_KEYBOARD)
        {
            [self setViewMovedUp:YES];
        }
    } else {
        NSIndexPath *indexPath = [self.currentOrderTableView indexPathForCell: (NewOrderCell *)(sender.superview.superview.superview)];
        [self.scrollView setContentOffset:CGPointMake(0, indexPath.row * ITEM_LIST_TABLE_ROW_HEIGHT_EXPANDED)  animated:YES];
    }
}

- (IBAction)textFinishEditing:(UITextField *)sender {
    
    [sender resignFirstResponder];
    
    if ([sender isEqual:self.addNotesTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y < 0)
        {
            [self setViewMovedUp:NO];
        }
    } else {
        NSIndexPath *indexPath = [self.currentOrderTableView indexPathForCell: (NewOrderCell *)(sender.superview.superview.superview)];
        Dish *dish = [self.userInfo.currentOrder.dishes objectAtIndex:indexPath.row];
        self.userInfo.currentOrder = [self.delegate addNote:sender.text toDish:dish];
    }
}

- (IBAction)plusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
    [BigSpoonAnimationController animateButtonWhenClicked:(UIView*)sender];
    
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.currentOrderTableView];
    NSIndexPath * indexPath = [self.currentOrderTableView indexPathForRowAtPoint: location];
    
    int dishID = sender.tag;
    
    NSLog(@"Added dish at row: %d with ID: %d", indexPath.row, dishID);

    
    NewOrderCell *cell = (NewOrderCell *)[self.currentOrderTableView cellForRowAtIndexPath: indexPath];
    
    
    self.userInfo.currentOrder = [self.delegate addDishWithID: dishID];
    cell.quantityLabel.text = [NSString stringWithFormat:@"%d", [self.userInfo.currentOrder getQuantityOfDishByID:dishID]];

    [self updatePriceLabels];
}

- (IBAction)minusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
    [BigSpoonAnimationController animateButtonWhenClicked:(UIView*)sender];

    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.currentOrderTableView];
    NSIndexPath * indexPath = [self.currentOrderTableView indexPathForRowAtPoint: location];
    
    int dishID = sender.tag;
    NSLog(@"Minus dish at row: %d with ID: %d", indexPath.row, dishID);
    self.userInfo.currentOrder = [self.delegate minusDishWithID: dishID];
    
    [self updatePriceLabels];
}

- (IBAction)placeOrderButtonPressed:(id)sender {
    NSLog(@"%@", [self.navigationController viewControllers]);
    [self dismissKeyboard];
    
    NSLog(@"%@", [self.delegate getCurrentOrder].notes);
    [[Mixpanel sharedInstance] track:@"ItemView: Order placed"];
    [[Mixpanel sharedInstance].people increment:@"Number of Order placed" by:[NSNumber numberWithInt:1]];
    [[Mixpanel sharedInstance] track: [NSString stringWithFormat:@"ItemView: Spent %@",self.pastTotalLabel.text]];
    [[Mixpanel sharedInstance].people increment:@"Total Spending" by: [NSNumber numberWithDouble: self.pastTotalLabel.text.doubleValue]];
    [[Mixpanel sharedInstance].people increment:@"Number of Dish" by: [NSNumber numberWithInt: [[User sharedInstance].pastOrder getTotalQuantity]]];
    
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
    self.userInfo.currentOrder = currentOrder;
    self.userInfo.pastOrder = pastOrder;
    [self.currentOrderTableView reloadData];
    [self.pastOrderTableView reloadData];
    [self updatePriceLabels];
}

- (void) updatePriceLabels{
    [self updatePriceLabelsWithCurrentORder:self.userInfo.currentOrder
                              SubtotalLabel:self.currentSubtotalLabel
                         ServiceChargeLabel:self.currentServiceChargeLabel
                    ServiceChargeTitleLabel:self.currentServiceChargeTitleLabel
                                   GSTLabel:self.currentGSTLabel
                              GSTTitleLabel:self.currentGSTTitleLabel
                              andTotalLabel:self.currentTotalLabel];
    
    [self updatePriceLabelsWithCurrentORder:self.userInfo.pastOrder
                              SubtotalLabel:self.pastSubtotalLabel
                         ServiceChargeLabel:self.pastServiceChargeLabel
                    ServiceChargeTitleLabel:self.pastServiceChargeTitleLabel
                                   GSTLabel:self.pastGSTLabel
                              GSTTitleLabel:self.pastGSTTitleLabel
                              andTotalLabel:self.pastTotalLabel];
    [self.pastOrderTableView reloadData];
    [self.currentOrderTableView reloadData];
    [self updateTablesAndScrollviewHeight : NO];
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
- (void) updateTablesAndScrollviewHeight: (BOOL) shouldUpdateViewPoint{
    int currentOrderTableHeight, oldOrderTableHeight;
    int numOfCurrentOrder = [self.userInfo.currentOrder getNumberOfKindsOfDishes];
    if (self.isAddingNotes){
        currentOrderTableHeight = ITEM_LIST_TABLE_ROW_HEIGHT_EXPANDED * numOfCurrentOrder;
        oldOrderTableHeight = ITEM_LIST_TABLE_ROW_HEIGHT * numOfCurrentOrder;
    } else {
        currentOrderTableHeight = ITEM_LIST_TABLE_ROW_HEIGHT * numOfCurrentOrder;
        oldOrderTableHeight = ITEM_LIST_TABLE_ROW_HEIGHT_EXPANDED * numOfCurrentOrder;
    }
    
    if (shouldUpdateViewPoint) {
        // set view point
        CGPoint oldContentOffset = self.scrollView.contentOffset;
        [self.scrollView setContentOffset:CGPointMake(0, oldContentOffset.y + (currentOrderTableHeight - oldOrderTableHeight))  animated:YES];
    }
    
    int pastOrderTableHeight = ORDERED_ITEM_LIST_TABLE_ROW_HEIGHT * [self.userInfo.pastOrder getNumberOfKindsOfDishes];
    
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
    [UIView animateWithDuration:0.25 animations:^{
        [self.viewContainerForAfterCurrentOrderTable setFrame:CGRectMake(viewAfterframe.origin.x,
                                                                         currentOrderFrame.origin.y + currentOrderTableHeight,
                                                                         viewAfterframe.size.width,
                                                                         viewAfterframe.size.height)];
    }];
    
    viewAfterframe = self.viewContainerForAfterPastOrderTable.frame;
    [self.viewContainerForAfterPastOrderTable setFrame:CGRectMake(viewAfterframe.origin.x,
                                                                  pasrOrderFrame.origin.y + pastOrderTableHeight,
                                                                  viewAfterframe.size.width,
                                                                  viewAfterframe.size.height)];
    self.scrollView.contentSize =CGSizeMake(ITEM_LIST_SCROLL_WIDTH, ITEM_LIST_SCROLL_HEIGHT + 100 + currentOrderTableHeight + pastOrderTableHeight);
    
    // hack for 3.5 and 4 screen size
    if (fabsf([[UIScreen mainScreen] bounds].size.height - IPHONE_35_INCH_HEIGHT) < 0.001) {
       self.scrollView.contentSize =CGSizeMake(ITEM_LIST_SCROLL_WIDTH, ITEM_LIST_SCROLL_HEIGHT + 100 + currentOrderTableHeight + pastOrderTableHeight);
    } else { // 4 inch
        self.scrollView.contentSize =CGSizeMake(ITEM_LIST_SCROLL_WIDTH, ITEM_LIST_SCROLL_HEIGHT + currentOrderTableHeight + pastOrderTableHeight);
    }
    
}


@end
