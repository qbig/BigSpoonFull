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
    double serviceCharge = 0.1 * subtotal;
    self.serviceChargeLabel.text = [NSString stringWithFormat:@"$%.2f", serviceCharge];
    double gst = 0.07 * (subtotal + serviceCharge);
    self.gstLabel.text = [NSString stringWithFormat:@"$%.2f", gst];
    self.totalLabel.text = [NSString stringWithFormat:@"$%.2f", subtotal + serviceCharge + gst];
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
    if ([[self.navigationController viewControllers] count] == 4) {
        return YES;
    }
    else {
        return NO;
    }
}

- (IBAction)placeTheSameOrder:(id)sender {
    NSLog(@"%@", [self.navigationController viewControllers]);
    OutletsTableViewController *outletsTableViewController = (OutletsTableViewController *)[[self.navigationController viewControllers] objectAtIndex:0];
    NSMutableArray *newViewControllers = [[NSMutableArray alloc] initWithObjects: outletsTableViewController, nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MenuViewController *menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"MENU_VIEW_CONTROLLER"];
    Outlet *outlet;
    for (Outlet *restaurant in outletsTableViewController.outletsArray) {
        if (restaurant.outletID == self.restaurantID) {
            outlet = restaurant;
        }
    }
    menuViewController.outlet = outlet;
    menuViewController.delegate = outletsTableViewController;
    Order* pastOrder = [[Order alloc] init];
    for (NSDictionary *meal in self.meals) {
        double quantity = [[meal objectForKey:@"quantity"] doubleValue];
        int dishID = [[[meal objectForKey:@"dish"] objectForKey:@"id"] integerValue];
        double price = [[[meal objectForKey:@"dish"] objectForKey:@"price"] doubleValue];
        Dish* pastOrderDish = [[Dish alloc] initWithName:[NSString stringWithFormat:@"%@", [[meal objectForKey:@"dish"] objectForKey:@"name"]] Description:[[NSString alloc] init] Price:price Ratings:-1 ID:dishID categories:nil imgURL:nil pos:-1 startTime:nil endTime:nil quantity:-1];
        Order* orderContainingThisMeal = [[Order alloc] init];
        for (int i = 0; i < quantity; i++) {
            [orderContainingThisMeal addDish:pastOrderDish];
        }
        [pastOrder mergeWithAnotherOrder:orderContainingThisMeal];
    }
    NSLog(@"%d", [pastOrder.dishes count]);
    if ([self hasUserComeFromMenuViewController]) {
        MenuViewController *oldMenuViewController = (MenuViewController*)[[self.navigationController viewControllers] objectAtIndex:1];
        if (oldMenuViewController.outlet.outletID == outlet.outletID) {
            [newViewControllers addObject:menuViewController];
            [pastOrder mergeWithAnotherOrder:oldMenuViewController.currentOrder];
            menuViewController.currentOrder = pastOrder;
            menuViewController.pastOrder = oldMenuViewController.pastOrder;
            menuViewController.tableID = oldMenuViewController.tableID;
        } else {
            [newViewControllers addObject:menuViewController];
            menuViewController.currentOrder = pastOrder;
        }
    } else {
        [newViewControllers addObject:menuViewController];
        if (outlet.outletID == outletsTableViewController.outletIDOfPreviousSelection) {
            [pastOrder mergeWithAnotherOrder:outletsTableViewController.currentOrder];
            menuViewController.pastOrder = outletsTableViewController.pastOrder;
            menuViewController.tableID = outletsTableViewController.tableIDOfPreviousSelection;
        }
        menuViewController.currentOrder = pastOrder;
    }
    menuViewController.isSupposedToShowItems = YES;
    [self.navigationController setViewControllers:newViewControllers animated:YES];
}

@end