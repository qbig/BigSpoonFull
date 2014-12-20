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
@property (nonatomic, strong) Dish* targetingDish;
@property (nonatomic, strong) NSIndexPath* lastInteractiveCellIndex;
@property (nonatomic, strong) NewOrderCell* cellPrototypeForCurrentOrders;
@property (nonatomic, strong) PastOrderCell* cellPrototypeForPastOrders;
@property (nonatomic, strong) NSMutableDictionary* dicForRowHeight;
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
    
    static NSString *CellIdentifierForCurrentOrders = @"NewOrderCell";
    self.cellPrototypeForCurrentOrders = [self.currentOrderTableView dequeueReusableCellWithIdentifier:CellIdentifierForCurrentOrders];
    
    static NSString *CellIdentifierForPastOrders = @"PastOrderCell";
    self.cellPrototypeForPastOrders = [self.pastOrderTableView dequeueReusableCellWithIdentifier:CellIdentifierForPastOrders];
    
    self.dicForRowHeight = [[NSMutableDictionary alloc] init];
    [TestFlight passCheckpoint:@"CheckPoint:User at Items Page"];
}


- (void) viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateCurrentOrderOffset {
    if ([self.userInfo.currentOrder.dishes count] == 0){
        [self.scrollView setContentOffset:
         CGPointMake(0, -self.scrollView.contentInset.top + ITEM_PAGE_EMPTY_CURRENT_ORDER_OFFSET) animated:YES];
    } else {
        [self.scrollView setContentOffset:
         CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePriceLabels) name:NOTIF_ORDER_UPDATE object:nil];
    [super viewWillAppear:animated];
    self.userInfo = [User sharedInstance];
    [self updatePriceLabels];
    [self updateCurrentOrderOffset];
    return;
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
        return [self.userInfo.currentOrder.dishes count];
    } else if ([tableView isEqual:self.pastOrderTableView]){
        return [self.userInfo.pastOrder.dishes count];
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

        if (self.isAddingNotes){
            cell.orderNote.hidden = NO;
        } else {
            cell.orderNote.hidden = YES;
        }
        int dishQuantity = [[self.userInfo.currentOrder.quantity objectAtIndex:indexPath.row] intValue];
        cell.nameLabel.text = dish.name;
        cell.quantityLabel.text = [NSString stringWithFormat:@"%d", dishQuantity];
        cell.plusButton.tag = dish.ID;
        cell.minusButton.tag = dish.ID;
        cell.orderNote.text = [self.userInfo.currentOrder getNoteForDishAtIndex:indexPath.row];

        if(dish.canBeCustomized){
            cell.modifierDetailsLabel.text = [self.userInfo.currentOrder getModifierDetailsTextAtIndex:indexPath.row];
            CGRect modifierFrame = cell.modifierDetailsLabel.frame;
            modifierFrame.origin.x = 86;
            modifierFrame.origin.y = 45;
            cell.modifierDetailsLabel.frame = modifierFrame;
            
            cell.priceLabel.text = [NSString stringWithFormat:@"$%.1f", dish.price + [dish.customOrderInfo getPriceChange]];
        } else {
            cell.modifierDetailsLabel.text = @"";
            cell.priceLabel.text = [NSString stringWithFormat:@"$%.1f", dish.price * dishQuantity];
        }
        return cell;
    } else if ([tableView isEqual:self.pastOrderTableView]){
        PastOrderCell *cell = (PastOrderCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"PastOrderCell"];
        
        Dish *dish = [self.userInfo.pastOrder.dishes objectAtIndex:indexPath.row];
        int dishQuantity = [[self.userInfo.pastOrder.quantity objectAtIndex:indexPath.row] intValue];
        cell.nameLabel.text = dish.name;
        cell.quantityLabel.text = [NSString stringWithFormat:@"%d", dishQuantity];

        if(dish.canBeCustomized){
            cell.modifierDetailsLabel.text = [self.userInfo.pastOrder getModifierDetailsTextAtIndex:indexPath.row];
            
            CGRect modifierFrame = cell.modifierDetailsLabel.frame;
            modifierFrame.origin.x = 86;
            modifierFrame.origin.y = 45;
            cell.modifierDetailsLabel.frame = modifierFrame;
            
            cell.priceLabel.text = [NSString stringWithFormat:@"$%.1f", dish.price + [dish.customOrderInfo getPriceChange]];
        } else {
            cell.modifierDetailsLabel.text = @"";
            cell.priceLabel.text = [NSString stringWithFormat:@"$%.1f", dish.price * dishQuantity];
        }
        
        return cell;
    } else{
        NSLog(@"Unrecognized tableView is calling delegate method");
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    double rowHeightForCurrentOrder;
    if ([tableView isEqual:self.currentOrderTableView]) {
        Dish *dish = [self.userInfo.currentOrder.dishes objectAtIndex:indexPath.row];
        if (dish.canBeCustomized){
            @try
            {
                self.cellPrototypeForCurrentOrders.modifierDetailsLabel.text = [self.userInfo.currentOrder getModifierDetailsTextAtIndex: indexPath.row];
                [self.cellPrototypeForCurrentOrders layoutSubviews];
                rowHeightForCurrentOrder = self.cellPrototypeForCurrentOrders.requiredCellHeight;
            }
            @catch (NSException *e)
            {
                NSLog(@"Exception: %@", e);
                rowHeightForCurrentOrder = ITEM_LIST_TABLE_ROW_HEIGHT;
            }
        } else {
            rowHeightForCurrentOrder = ITEM_LIST_TABLE_ROW_HEIGHT;
        }
        [self.dicForRowHeight setObject:[NSNumber numberWithDouble: rowHeightForCurrentOrder]forKey: [NSString stringWithFormat: @"current-%d", indexPath.row]];
        
        if(self.isAddingNotes){
            return rowHeightForCurrentOrder + ITEM_LIST_ADD_NOTE_TEXT_FIELD_HEIGHT;
        } else {
            return rowHeightForCurrentOrder;
        }
    } else if ([tableView isEqual:self.pastOrderTableView]){
        Dish *dish = [self.userInfo.pastOrder.dishes objectAtIndex:indexPath.row];
        if (dish.canBeCustomized){
            @try
            {
                self.cellPrototypeForPastOrders.modifierDetailsLabel.text = [self.userInfo.pastOrder getModifierDetailsTextAtIndex: indexPath.row];
                [self.cellPrototypeForPastOrders layoutSubviews];
                rowHeightForCurrentOrder = self.cellPrototypeForPastOrders.requiredCellHeight;
            }
            @catch (NSException *e)
            {
                NSLog(@"Exception: %@", e);
                rowHeightForCurrentOrder = ITEM_LIST_TABLE_ROW_HEIGHT;
            }
        } else {
            rowHeightForCurrentOrder = ITEM_LIST_TABLE_ROW_HEIGHT;
        }
        [self.dicForRowHeight setObject:[NSNumber numberWithDouble: rowHeightForCurrentOrder]forKey: [NSString stringWithFormat: @"past-%d", indexPath.row]];
        
        return rowHeightForCurrentOrder;
    } else{
        NSLog(@"Unrecognized tableView is calling delegate method");
        return ITEM_LIST_TABLE_ROW_HEIGHT;
    }
}

- (double) getSectionHeightForCurrentOrdersUntilRow: (int) rowNum {
    // for current orders
    double result = 0;
    for(int i = 0 ; i < rowNum; i++){
        result += [[self.dicForRowHeight objectForKey:[NSString stringWithFormat: @"current-%d", i]] doubleValue];
    }
    return result;
}

- (double) getSectionHeightForPastOrdersUntilRow: (int) rowNum {
    // for past orders
    double result = 0;
    for(int i = 0 ; i < rowNum; i++){
        result += [[self.dicForRowHeight objectForKey:[NSString stringWithFormat: @"past-%d", i]] doubleValue];
    }
    return result;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToEditDishModifier"]) {
        DishModifierTableViewController *modifierPopup = segue.destinationViewController;
        modifierPopup.targetingDish = self.targetingDish;
        modifierPopup.delegate = self;
        [modifierPopup.targetingDish.customOrderInfo setAnswer: [self.userInfo.currentOrder getModifierAnswerAtIndex:self.lastInteractiveCellIndex.row ]];
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target: nil action: nil];
        [[self navigationItem] setBackBarButtonItem: newBackButton];
        
    } else{
        NSLog(@"Segureee in the ItemsOrderedViewController cannot assign delegate to its segue. Segue identifier: %@", segue.identifier);
    }

}

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
        [self.scrollView setContentOffset:CGPointMake(0, [self getSectionHeightForCurrentOrdersUntilRow: indexPath.row])  animated:YES];
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
        self.userInfo.currentOrder = [self.delegate addNote:sender.text toDishAtIndex:indexPath.row];
    }
}

- (IBAction)plusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
    [BigSpoonAnimationController animateButtonWhenClicked:(UIView*)sender];
    
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.currentOrderTableView];
    NSIndexPath * indexPath = [self.currentOrderTableView indexPathForRowAtPoint: location];
    
    int dishID = sender.tag;
    NSLog(@"Added dish at row: %d with ID: %d", indexPath.row, dishID);
    
    self.targetingDish = (Dish *) [self.userInfo.currentOrder.dishes objectAtIndex: indexPath.row];
    if( self.targetingDish.canBeCustomized) {
        self.lastInteractiveCellIndex = indexPath;
        [self performSegueWithIdentifier:@"SegueToEditDishModifier" sender:self];
    } else {
        self.userInfo.currentOrder = [self.delegate addDishWithIndex: indexPath.row];
        [self updatePriceLabels];
    }
}

- (IBAction)minusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
    [BigSpoonAnimationController animateButtonWhenClicked:(UIView*)sender];

    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.currentOrderTableView];
    NSIndexPath * indexPath = [self.currentOrderTableView indexPathForRowAtPoint: location];
    
    int dishID = sender.tag;
    NSLog(@"Minus dish at row: %d with ID: %d", indexPath.row, dishID);
    self.userInfo.currentOrder = [self.delegate minusDishWithIndex: indexPath.row];
    
    [self updatePriceLabels];
    [self updateCurrentOrderOffset];
}

- (IBAction)placeOrderButtonPressed:(id)sender {
    NSLog(@"%@", [self.navigationController viewControllers]);
    NSLog(@"%@", [self.delegate getCurrentOrder].notes);
    [self dismissKeyboard];
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
    [self updateCurrentOrderOffset];
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
    serviceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", serviceCharge];
 
    float GST = subTotal * GSTRate;
    GSTTitleLabel.text = [NSString stringWithFormat:@"GST (%.0f%%):", GSTRate * 100];
    GSTLabel.text = [NSString stringWithFormat:@"$%.2f", GST];
    
    float total = subTotal + serviceCharge + GST;
    totalLabel.text = [NSString stringWithFormat:@"$%.2f", total];
}

/*
 * The table height is dynamic.
 */
- (void) updateTablesAndScrollviewHeight: (BOOL) shouldUpdateViewPoint{
    int currentOrderTableHeight, oldCurrentOrderTableHeight;
    int numOfCurrentOrder = [self.userInfo.currentOrder.dishes count];
    int numOfPastOrder = [self.userInfo.pastOrder.dishes count];
    if (self.isAddingNotes){
        currentOrderTableHeight =  [self getSectionHeightForCurrentOrdersUntilRow: numOfCurrentOrder] + numOfCurrentOrder * ITEM_LIST_ADD_NOTE_TEXT_FIELD_HEIGHT;
        oldCurrentOrderTableHeight = [self getSectionHeightForCurrentOrdersUntilRow: numOfCurrentOrder];
    } else {
        currentOrderTableHeight = [self getSectionHeightForCurrentOrdersUntilRow: numOfCurrentOrder];
        oldCurrentOrderTableHeight = [self getSectionHeightForCurrentOrdersUntilRow: numOfCurrentOrder] + numOfCurrentOrder * ITEM_LIST_ADD_NOTE_TEXT_FIELD_HEIGHT;
    }
    
    
    if (shouldUpdateViewPoint) {
        // set view point
        CGPoint oldContentOffset = self.scrollView.contentOffset;
        [self.scrollView setContentOffset:CGPointMake(0, oldContentOffset.y + (currentOrderTableHeight - oldCurrentOrderTableHeight))  animated:YES];
    }
    
    int pastOrderTableHeight = [self getSectionHeightForPastOrdersUntilRow:numOfPastOrder];
    
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
    if ([self.userInfo.currentOrder.dishes count] == 0){
        pastOrderTableHeight += ITEM_PAGE_EMPTY_CURRENT_ORDER_OFFSET;
    }
    // hack for 3.5 and 4 screen size
    if (fabsf([[UIScreen mainScreen] bounds].size.height - IPHONE_35_INCH_HEIGHT) < 0.001) {
       self.scrollView.contentSize =CGSizeMake(ITEM_LIST_SCROLL_WIDTH, ITEM_LIST_SCROLL_HEIGHT + 100 + currentOrderTableHeight + pastOrderTableHeight);
    } else { // 4 inch
        self.scrollView.contentSize =CGSizeMake(ITEM_LIST_SCROLL_WIDTH, ITEM_LIST_SCROLL_HEIGHT + currentOrderTableHeight + pastOrderTableHeight);
    }
    
}

#pragma mark - DishModifierSegueDelegate 

- (void) dishModifierPopupDidSaveWithUpdatedModifier:(Dish *)newDishWithModifier {
    [self.delegate addDish:newDishWithModifier];
}

- (void) dishModifierPopupDidCancel{
    
}
@end
