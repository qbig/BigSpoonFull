//
//  PastOrderDetailViewController.m
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 19/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "PastOrderDetailViewController.h"

@interface PastOrderDetailViewController ()

-(double)getSubtotal;

-(BOOL)hasUserComeFromMenuViewController;

@end


@implementation PastOrderDetailViewController
@synthesize subtotalContainterView;
@synthesize scrollview;
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
	// Do any additional setup after loading the view.
    self.restuarantNameLabel.text = self.restaurantName;
    self.orderTimeLabel.text = self.orderTime;
    [self updateTablesAndScrollviewHeight];
    [[Mixpanel sharedInstance] track:@"User reach history Detail View"];
}

- (double)getSubtotal {
    double subtotal = 0.0;
    for (NSDictionary *meal in self.meals) {
        NSLog(@"%@", meal);
        double quantity = [[meal objectForKey:@"quantity"] doubleValue];
        double price = [[[meal objectForKey:@"dish"] objectForKey:@"price"] doubleValue];
        subtotal = subtotal + quantity * price;
    }
    return subtotal;
}

- (void) viewWillAppear:(BOOL)animated
{
    double subtotal = [self getSubtotal];
    self.subtotalLabel.text = [NSString stringWithFormat:@"$%.2f", subtotal];
    double serviceCharge = 0 * subtotal;
    self.serviceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", serviceCharge];
    double gst = 0 * (subtotal + serviceCharge);
    self.gstLabel.text = [NSString stringWithFormat:@"$%.2f", gst];
    self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", subtotal + serviceCharge + gst];
    
    [TestFlight passCheckpoint:@"CheckPoint:User Checking Past Order Details"];
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
    return [self.meals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mealItem"];
    UILabel *lblQuantity = (UILabel *)[cell viewWithTag:101];
    UILabel *lblName = (UILabel *)[cell viewWithTag:102];
    UILabel *lblPrice = (UILabel *)[cell viewWithTag:103];
    [lblQuantity setText:[NSString stringWithFormat:@"%@", [[self.meals objectAtIndex:[indexPath row]] objectForKey:@"quantity"]]];
    [lblName setText:[NSString stringWithFormat:@"%@", [[[self.meals objectAtIndex:[indexPath row]] objectForKey:@"dish"] objectForKey:@"name"]]];
    [lblPrice setText:[NSString stringWithFormat:@"$%@", [[[self.meals objectAtIndex:[indexPath row]] objectForKey:@"dish"] objectForKey:@"price"]]];
    return cell;
}

-(BOOL)hasUserComeFromMenuViewController {
    return [[self.navigationController viewControllers] count] == 4;
}

- (void) updateTablesAndScrollviewHeight{
    int currentOrderTableHeight = 29 * [self.meals count];
    
    CGRect currentOrderFrame = self.mealsTableView.frame;
    [self.mealsTableView setFrame: CGRectMake(currentOrderFrame.origin.x,
                                                     currentOrderFrame.origin.y,
                                                     currentOrderFrame.size.width,
                                                     currentOrderTableHeight)];
    
    CGRect viewAfterframe = self.subtotalContainterView.frame;
    [self.subtotalContainterView setFrame:CGRectMake(viewAfterframe.origin.x,
                                                                     currentOrderFrame.origin.y + currentOrderTableHeight,
                                                                     viewAfterframe.size.width,
                                                                     viewAfterframe.size.height)];
    

    self.scrollview.contentSize = CGSizeMake(ITEM_LIST_SCROLL_WIDTH, self.subtotalContainterView.frame.origin.y + self.subtotalContainterView.frame.size.height + HISTORY_DETAIL_SCROLLING_EXTRA);
}

- (Order *)getFlattenedSelectedPastOrder {
    Order* pastOrder = [[Order alloc] init];
    for (NSDictionary *meal in self.meals) {
        double quantity = [[meal objectForKey:@"quantity"] doubleValue];
        int dishID = [[[meal objectForKey:@"dish"] objectForKey:@"id"] integerValue];
        double price = [[[meal objectForKey:@"dish"] objectForKey:@"price"] doubleValue];
        Dish* pastOrderDish = [[Dish alloc] initWithName:[NSString stringWithFormat:@"%@", [[meal objectForKey:@"dish"] objectForKey:@"name"]] Description:[[NSString alloc] init] Price:price Ratings:-1 ID:dishID categories:nil imgURL:nil pos:-1 index:0 startTime:nil endTime:nil quantity:-1 canBeCustomized:false customOrderInfo:nil];
        Order* orderContainingThisMeal = [[Order alloc] init];
        for (int i = 0; i < quantity; i++) {
            [orderContainingThisMeal addDish:pastOrderDish];
        }
        [pastOrder mergeWithAnotherOrder:orderContainingThisMeal];
    }
    return pastOrder;
}

- (void)mergeSelectedPastOrderWithCurretOrder {
    Order *pastOrder = [self getFlattenedSelectedPastOrder];
    User *user = [User sharedInstance];
    if (self.selectedPastOrderOutletId == user.currentLoadedOutlet.outletID){
        [pastOrder mergeWithAnotherOrder:[user.currentSession getCurrentOrder]];
        [user.currentSession setCurrentOrder: pastOrder];
    } else {
        [user.currentSession setCurrentOrder: pastOrder];
    }
}

- (IBAction)placeTheSameOrder:(id)sender {
    
    [[Mixpanel sharedInstance] track:@"User click Same order in history"];
    OutletsTableViewController *outletsTableViewController = (OutletsTableViewController *)[[self.navigationController viewControllers] objectAtIndex:0];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MenuViewController *menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"MENU_VIEW_CONTROLLER"];
    menuViewController.delegate = outletsTableViewController;
    menuViewController.arrivedFromOrderHistory = YES;
    menuViewController.jsonForDishesTablesAndCategories = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%d",OUTLET_INFO_FOR_ID_PREFIX ,self.selectedPastOrderOutletId]];
    // set outlet
    for (Outlet *outlet in outletsTableViewController.outletsArray) {
        if (outlet.outletID == self.selectedPastOrderOutletId) {
            menuViewController.outlet = outlet;
        }
    }
    
    [self mergeSelectedPastOrderWithCurretOrder];
    NSMutableArray *newViewControllers = [[NSMutableArray alloc] initWithObjects: outletsTableViewController, menuViewController, nil];
    [self.navigationController setViewControllers:newViewControllers animated:YES];
}

@end