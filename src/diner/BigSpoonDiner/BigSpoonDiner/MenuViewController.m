//
//  MenuViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController (){
    void (^taskAfterAskingForTableID)(void);
    NSMutableDictionary *_viewControllersByIdentifier;
    NSString *notesWhenPlacingOrder;
    CGRect oldFrameItemBadge;
    NSDictionary *_validTableIDs;
}

@property (nonatomic, strong) UIAlertView *requestForWaiterAlertView;
@property (nonatomic, strong) UIAlertView *requestForBillAlertView;
@property (nonatomic, strong) UIAlertView *inputTableIDAlertView;
@property (nonatomic, strong) UIAlertView *placeOrderAlertView;
@property (nonatomic, strong) UIAlertView *goBackButtonPressedAlertView;

@property (nonatomic, copy) void (^taskAfterAskingForTableID)(void);

- (BOOL) isUserLocation:(CLLocation *)userLocation WithinMeters:(double)radius OfLatitude:(double)lat AndLongitude:(double)lon;
- (BOOL) isLocation:(CLLocation *)locationA SameAsLocation:(CLLocation *)locationB;

@end

@implementation MenuViewController

@synthesize outlet;
@synthesize menuListViewController;
@synthesize requestWaterView;

@synthesize quantityOfColdWater;
@synthesize quantityOfWarmWater;

@synthesize quantityOfColdWaterLabel;
@synthesize quantityOfWarmWaterLabel;
@synthesize requestForWaiterAlertView;
@synthesize requestForBillAlertView;
@synthesize inputTableIDAlertView;
@synthesize taskAfterAskingForTableID;
@synthesize navigationItem;
@synthesize jsonForDishesTablesAndCategories;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tableID = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Record the frame of badge
    oldFrameItemBadge = self.itemQuantityLabelBackgroundImageView.frame;
    self.userInfo = [User sharedInstance];
    // Set the Outlet Name to be the title
    [self.navigationItem setTitle: [self regulateLengthOfString: self.outlet.name]];
    _viewControllersByIdentifier = [NSMutableDictionary dictionary];
    // If the ordered items are null, init them.
    // If not, update the badge.
    if ([self.userInfo.currentOrder getTotalQuantity] + [self.userInfo.pastOrder getTotalQuantity] == 0) {
        self.userInfo.currentOrder = [[Order alloc]init];
        self.userInfo.pastOrder = [[Order alloc]init];
    } else{
        [self updateItemQuantityBadge];
    }
    
    [self loadControlPanels];
}

-(void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"View will appear lah");
    if (self.arrivedFromOrderHistory) {
        [self itemsButtonPressed:nil];
    }
    self.userInfo = [User sharedInstance];
    [super viewWillAppear:animated];
    
    // The toolbar that contains the bar button items
    // The toolbar is hidden (set in storyboard, x = -100)
    // Its bar button items is inserted to the navigationController
    // The buttons are hidden by default. Because don't wanna show their moving trace.
    // They will shown in viewDidAppear:
    [self.settingsButton setHidden:YES];
    [self.viewModeButton setHidden:YES];
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects: self.settingsBarButton, self.viewModeBarButton, nil];
    
}

-(void) viewDidAppear:(BOOL)animated {
    
    NSLog(@"View Did Appear asdfasdfa");
    
    [super viewDidAppear:animated];
    
    if (self.childViewControllers.count < 1) {
        [self performSegueWithIdentifier:@"SegueFromMenuToList" sender:self];
    }
    
    // If the user is currently viewing the selected items, we should hide the "viewModeButton"
    // Because its function is replaced by the "< Menu" button at the top-left
    if ([self.destinationIdentifier isEqualToString:@"SegueFromMenuToItems"]) {
        [self.viewModeButton setHidden:YES];
        [self.settingsButton setHidden:NO];
        
        // Put back the "gear" button. Otherwise the "gear" button will be located at the top-left corner.
        [self changeBackButtonTo:@"back.png" withAction:@selector(viewModeButtonPressedAtOrderPage:)];

    } else{
        [self.viewModeButton setHidden:NO];
        [self.settingsButton setHidden:NO];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        
        NSString *message = @"";
        if ([self.userInfo.currentOrder getTotalQuantity] != 0) {
            message = @"You have selected some food but haven't placed the order. You can come back later to place the order";
        }
        if ([self.userInfo.pastOrder getTotalQuantity] != 0){
            message = @"You have unpaid items. You can come back later to pay the bill";
        }
        if ([self.userInfo.currentOrder getTotalQuantity] != 0 && [self.userInfo.pastOrder getTotalQuantity] != 0) {
            message = @"You have unorderd and unpaid items. You can come back later";
        }
        
        // If the user has selected/ordered anything:
        if (![message isEqualToString:@""]) {
            
            [self.delegate exitMenuListWithCurrentOrder:self.userInfo.currentOrder
                                              PastOrder:self.userInfo.pastOrder
                                               OutletID:self.outlet.outletID
                                             andTableID:self.tableID
                                             andMessage:message];
            
        }
    }
    
    [super viewWillDisappear:animated];
}

- (void) loadControlPanels{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"RequestWaterView" owner:self options:nil];
    self.requestWaterView = [subviewArray objectAtIndex:0];
    [self.view addSubview:self.requestWaterView];
    CGRect frame = self.requestWaterView.frame;
    [self.requestWaterView setFrame: [self getFrameAtCenterOfScreenWithWidth:frame.size.width andHeight:frame.size.height]];
    
    [BigSpoonAnimationController animateTransitionOfUIView:self.requestWaterView willShow:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Geo Location

// Failed to get current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorString;
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"Dear customer, you may want to enable location to use BigSpoon";
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Location data unavailable";
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            break;
    }

 //   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
 //   [alert show];
}

- (BOOL) isUserLocation:(CLLocation *)userLocation WithinMeters:(double)radius OfLatitude:(double)lat AndLongitude:(double)lon
{
    if (userLocation == nil){
        return false;
    }
    if ([self meAtPgpBusStop:userLocation WithinMeters:1500]){
        return true;
    }
    
    CLLocation *outletLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    CLLocationDistance distance = [userLocation distanceFromLocation:outletLocation];
    if (distance <= radius) {
        return true;
    } else {
        return false;
    }
}

- (BOOL) meAtPgpBusStop :(CLLocation *)userLocation WithinMeters:(double)radius{
    // assuming location available
    CLLocation *pgpBusStopLocation = [[CLLocation alloc] initWithLatitude:1.292026 longitude:103.780304];
    CLLocation *pgp5Location = [[CLLocation alloc] initWithLatitude:1.293208 longitude:103.778376];
    
    CLLocationDistance distanceFromBusStop = [userLocation distanceFromLocation:pgpBusStopLocation];
    CLLocationDistance distanceFromPgp5 = [userLocation distanceFromLocation:pgp5Location];
    User *user = [User sharedInstance];
    if (distanceFromBusStop <= radius && distanceFromPgp5 <= radius && ( [user.email isEqualToString:@"qiaoliang89@yahoo.com.cn"] || [user.email isEqualToString:@"jay.tjk@gmail.com"])) {
        return true;
    } else {
        return false;
    }
}

- (BOOL) isLocation:(CLLocation *)locationA SameAsLocation:(CLLocation *)locationB {
    if ((locationA.coordinate.latitude == locationB.coordinate.latitude) && (locationA.coordinate.longitude == locationB.coordinate.longitude)) {
        return true;
    }
    else {
        return false;
    }
}

- (NSString *) regulateLengthOfString:(NSString *)String{
    NSString *toReturn = String;
    if ([String length] >= MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM) {
        toReturn = [String substringToIndex: MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM - 3];
        toReturn = [toReturn stringByAppendingString:@"..."];
    }
    return toReturn;
}

#pragma mark ButtonClick Event Listeners

- (void)toggleDisplayModeAndReloadData {
    NSLog(@"viewModeButtonPressedAtListPage");
    if (self.menuListViewController.displayMethod == kMethodList){
        self.menuListViewController.displayMethod = kMethodPhoto;
        [self changeViewModeButtonIconTo:@"list_icon.png"];
        
        [TestFlight passCheckpoint:@"CheckPoint:User Checking Picture Menu"];
        [[Mixpanel sharedInstance].people increment:@"MenuView: User at Pic Menu" by: [NSNumber numberWithInt:1]];
    } else if (self.menuListViewController.displayMethod == kMethodPhoto){
        self.menuListViewController.displayMethod = kMethodList;
        [self changeViewModeButtonIconTo:@"photo_icon.png"];
        
        [TestFlight passCheckpoint:@"CheckPoint:User Checking List Menu"];
        [[Mixpanel sharedInstance].people increment:@"User at List Menu" by: [NSNumber numberWithInt:1]];
    } else {
        NSLog(@"Error: In viewModeButtonPressedAtListPage(), displayMethod not found");
    }
    
    [self.menuListViewController.tableView reloadData];
}

- (IBAction)viewModeButtonPressedAtListPage:(id)sender {
    [self toggleDisplayModeAndReloadData];
}

- (IBAction)viewModeButtonPressedAtOrderPage:(id)sender{
    NSLog(@"viewModeButtonPressedAtOrderPage");
    // Change the function of button to: Go Back.
    [self.viewModeButton removeTarget:self action:@selector(viewModeButtonPressedAtOrderPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewModeButton addTarget:self action:@selector(viewModeButtonPressedAtListPage:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.menuListViewController.displayMethod == kMethodPhoto){
        [self changeViewModeButtonIconTo:@"list_icon.png"];
    } else{
        [self changeViewModeButtonIconTo:@"photo_icon.png"];
    }
    
    [self changeBackButtonTo:@"home_with_arrow.png" withAction:@selector(popTopViewControllerInNavigationStack)];
    
    [self.viewModeButton setHidden:NO];
    
    [self performSegueWithIdentifier:@"SegueFromMenuToList" sender:self];
}

- (void) popTopViewControllerInNavigationStack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingsButtonPressed:(id)sender {

    [self performSegueWithIdentifier:@"SegueFromMenuListToOrderHistory" sender:self];
}

- (IBAction)requestWaterButtonPressed:(id)sender {
    NSLog(@"requestWaterButtonPressed");

    [BigSpoonAnimationController animateRequestButtonWhenClicked:self.requestWaterButtonCoverView];

    if (![self isTableIDKnown]) {
        [[Mixpanel sharedInstance] track:@"MenuView: Request for Water(Not verified)"];
        [self askForTableID];
        
        __weak MenuViewController *weakSelf = self;
        
        self.taskAfterAskingForTableID = ^(void){
            [weakSelf performRequestWaterSelectQuantityPopUp];
        };
    } else{
        [[Mixpanel sharedInstance] track:@"MenuView: Request for Water"];
        [self performRequestWaterSelectQuantityPopUp];
    }
}

- (void) performRequestWaterSelectQuantityPopUp{
    [BigSpoonAnimationController animateTransitionOfUIView:self.requestWaterView willShow:YES];
}

- (IBAction)requestWaiterButtonPressed:(id)sender {
    [BigSpoonAnimationController animateRequestButtonWhenClicked:self.requestWaiterButtonCoverView];

    NSLog(@"callWaiterButtonPressed");
    
    if (![self isTableIDKnown]) {
        [[Mixpanel sharedInstance] track:@"MenuView: Request for Staff Waiters(Not verified) "];
        [self askForTableID];
        
        __weak MenuViewController *weakSelf = self;
        
        self.taskAfterAskingForTableID = ^(void){
            [weakSelf performRequestWaiterConfirmationPopUp];
        };
    } else{
        [self performRequestWaiterConfirmationPopUp];
        [[Mixpanel sharedInstance] track:@"MenuView: Request for Staff Waiters"];
    }
    [TestFlight passCheckpoint:@"CheckPoint:User Asking for Waiters"];
}

- (void) performRequestWaiterConfirmationPopUp{
    self.requestForWaiterAlertView = [[UIAlertView alloc]
                                 initWithTitle:@"Call For Service"
                                 message:@"Require assistance from the waiter?"
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"Yes", nil];
    [self.requestForWaiterAlertView show];
}

- (IBAction)requestBillButtonPressed:(id)sender {

    [BigSpoonAnimationController animateRequestButtonWhenClicked:self.requestBillButtonCoverView];

    
    // If the user hasn't ordered anything:
    if ([self.userInfo.pastOrder getTotalQuantity] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                     initWithTitle:@"Request Bill"
                                     message:@"You haven't ordered anything."
                                     delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"Okay", nil];
        [alertView show];
        
        return;
    }
    
    if (![self isTableIDKnown]) {
        [self askForTableID];
        [[Mixpanel sharedInstance] track:@"MenuView: Request for Bill(Not verified)"];
        __weak MenuViewController *weakSelf = self;
        
        self.taskAfterAskingForTableID = ^(void){
            [weakSelf performRequestBillConfirmationPopUp];
        };
    } else{
        [self performRequestBillConfirmationPopUp];
        [[Mixpanel sharedInstance] track:@"MenuView: Request for Bill"];
        [[Mixpanel sharedInstance].people increment:@"Number of Bill" by:[NSNumber numberWithInt:1]];
    }
    
    [TestFlight passCheckpoint:@"CheckPoint:User Asked For Bill"];
}

- (void) performRequestBillConfirmationPopUp{
    
    NSMutableString *message = [[NSMutableString alloc] init];
    
    // Append the price information to the message:
//    float subtotal = [self.userInfo.pastOrder getTotalPrice];
//    float gst = subtotal * self.outlet.gstRate;
//    float serviceCharge = subtotal * self.outlet.serviceChargeRate;
//    float totalPrice = subtotal + gst + serviceCharge;
//    int spaces_needed = 25;
//    [message appendFormat:@" Subtotal:%@%-3.2f\n",[@" " stringByPaddingToLength:spaces_needed withString:@" " startingAtIndex:0], subtotal];
//    [message appendFormat:@"GST(%.0f%%):%@%-3.2f\n", self.outlet.gstRate * 100, [@" " stringByPaddingToLength:spaces_needed withString:@" " startingAtIndex:0], gst];
//    [message appendFormat:@"Service Charge(%.0f%%):%@%-3.2f\n", self.outlet.serviceChargeRate * 100, [@" " stringByPaddingToLength:spaces_needed-17 withString:@" " startingAtIndex:0], serviceCharge];
//    [message appendFormat:@"      Total:%@%-3.2f", [@" " stringByPaddingToLength:spaces_needed withString:@" " startingAtIndex:0], totalPrice];
    
    self.requestForBillAlertView = [[UIAlertView alloc]
                               initWithTitle:@"Would you like your bill?"
                               message:message
                               delegate:self
                               cancelButtonTitle:@"Cancel"
                               otherButtonTitles:@"Yes", nil];

    [self.requestForBillAlertView show];
}

- (void) performRequestBillNetWorkRequest{
    
    NSMutableArray *dishesArray = [[NSMutableArray alloc] init];
    
    // For every dish that is currently in the order, we add it to the dishes dictionary:
    for (int i = 0; i < [self.userInfo.currentOrder.dishes count]; i++) {
        Dish *dish = [self.userInfo.currentOrder.dishes objectAtIndex:i];
        NSNumber * quantity = [NSNumber numberWithInt:[self.userInfo.currentOrder getQuantityOfDishByDish: dish]];
        NSString * ID = [NSString stringWithFormat:@"%d", dish.ID];
        
        NSDictionary *newPair = [NSDictionary dictionaryWithObject:quantity forKey:ID];
        [dishesArray addObject:newPair];
    }
    
    NSDictionary *parameters = @{
                                 @"table": [NSNumber numberWithInt: self.tableID],
                                 };
    
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: BILL_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        int responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{
                NSLog(@"Request Bill Success");
                [self afterSuccessfulRequestBill];
            }
                break;
            case 403:
            default:{
                NSLog(@"Request Bill Fail");
                [self displayErrorInfo: operation.responseObject];
            }
        }
        NSLog(@"JSON: %@", responseObject);
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [self displayErrorInfo: operation.responseObject];
                                      }];
    
    [operation start];
}

- (void) afterSuccessfulRequestBill{

    // Load and show the ratingAndFeedbackViewController:
    [self performSegueWithIdentifier:@"SegueFromMenuToRating" sender:self];
    
    // Set the order items to null
    self.userInfo.currentOrder = [[Order alloc] init];
    self.userInfo.pastOrder = [[Order alloc] init];
    self.tableID = -1;
}

- (IBAction)itemsButtonPressed:(id)sender {
    [[Mixpanel sharedInstance] track:@"MenuView: User reach Item page"];
    [BigSpoonAnimationController animateRequestButtonWhenClicked:self.itemsButtonCoverView];
    
    // Can also check in the shouldPerformSegueWithIdentifier:sender
    // But it doesn't work because it's manual segue
    if (![self.destinationIdentifier isEqualToString:@"SegueFromMenuToItems"]) {
        [self performSegueWithIdentifier:@"SegueFromMenuToItems" sender:self];
    }
}

- (void) changeViewModeButtonIconTo: (NSString *)picName{
    [self.viewModeButton setImage:[UIImage imageNamed:picName] forState:UIControlStateNormal];
    [self.viewModeButton setImage:[UIImage imageNamed:picName] forState:UIControlStateHighlighted];
}

- (void) changeBackButtonTo: (NSString *)picName withAction: (SEL) sel{
    
    UIImage *buttonImage = [UIImage imageNamed:picName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setImage:buttonImage forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, 0, 23 * SCALE_OF_BUTTON, 23); // Ratio: 128 * 46
    
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = customBarItem;

}

#pragma mark tableViewController Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Asked, hay!");
    return 4;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueFromMenuListToOrderHistory"]) {
        
        // Need to set the rightBarButtonItems to nil. Otherwise they will slide to the left.
        // They will be put back after viewDidAppear: function. That function will be called after the new view is poped.
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: nil];
        
        NSString *backButtonTitle = @"";
        if ([self.destinationIdentifier isEqualToString:@"SegueFromMenuToItems"]) {
            backButtonTitle = @"Items";
        } else if ([self.destinationIdentifier isEqualToString:@"SegueFromMenuToList"]) {
            backButtonTitle = @"Menu";
        }
        
        // Change the back button title. Cannot display title of restaurant, since it's too long to appear in the back button.
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: backButtonTitle style: UIBarButtonItemStyleBordered target: nil action: nil];
        [[self navigationItem] setBackBarButtonItem: newBackButton];
        
	} else if([segue isKindOfClass:[MultiContainerViewSegue class]]){
        
        self.oldViewController = self.destinationViewController;
        
        //if view controller isn't already contained in the viewControllers-Dictionary
        if (![_viewControllersByIdentifier objectForKey:segue.identifier]) {
            
            [_viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
            
            if ([segue.identifier isEqualToString:@"SegueFromMenuToList"]){
                
                self.menuListViewController = segue.destinationViewController;
                self.menuListViewController.outlet = self.outlet;
                self.menuListViewController.delegate = self;
                self.menuListViewController.jsonForDishesTablesAndCategories = self.jsonForDishesTablesAndCategories;
                
            } else if ([segue.identifier isEqualToString:@"SegueFromMenuToItems"]){
                
                self.itemsOrderedViewController = (ItemsOrderedViewController *)segue.destinationViewController;
                self.itemsOrderedViewController.delegate = self;
            }
        }
        
        self.destinationIdentifier = segue.identifier;
        self.destinationViewController = [_viewControllersByIdentifier objectForKey:self.destinationIdentifier];
        
        if ([segue.identifier isEqualToString:@"SegueFromMenuToList"]){
            
        }
        
        if([segue.identifier isEqualToString:@"SegueFromMenuToItems"]){
            
            // Make a new goBackButton
            [self changeBackButtonTo:@"back.png" withAction:@selector(viewModeButtonPressedAtOrderPage:)];
            
            // Change the function of button to: Go Back.
            [self.viewModeButton setHidden:YES];
            
            [self.itemsOrderedViewController setGSTRate: outlet.gstRate andServiceChargeRate:outlet.serviceChargeRate];
            
            [self.itemsOrderedViewController reloadOrderTablesWithCurrentOrder:self.userInfo.currentOrder andPastOrder:self.userInfo.pastOrder];
        }
        
    } else if ([segue.identifier isEqualToString:@"SegueFromMenuToRating"]){
        RatingAndFeedbackViewController* ratingAndFeedbackViewController = segue.destinationViewController;
        ratingAndFeedbackViewController.delegate = self;
        ratingAndFeedbackViewController.orderToRate = self.userInfo.pastOrder;
        ratingAndFeedbackViewController.outletID = self.outlet.outletID;
    }
    
    else{
        NSLog(@"Segure in the menuViewController cannot assign delegate to its segue. Segue identifier: %@", segue.identifier);
    }
}

- (void) cancelButtonPressed:(OrderHistoryViewController *)controller{
    NSLog(@"cancelled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Delegate Methods

- (void)modalSegueDidExit{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ratingAndFeedbackDidSubmitted{
    [self.view    makeToast:@"As a valued customer, your feedback is important to us and we will take it into consideration."
                             duration:TOAST_VIEW_DURATION
                             position:@"bottom"
                                title:@"Thank you"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([alertView isEqual:self.requestForBillAlertView]) {
        if([title isEqualToString:@"Yes"])
        {
            NSLog(@"Request For Bill");
            // TODO Make HTTP request for this.
            [self performRequestBillNetWorkRequest];
        }
        else if([title isEqualToString:@"Cancel"])
        {
            NSLog(@"Request For bill Canceled");
        }else{
            NSLog(@"Unrecognized button pressed");
        }
    }
    
    else if ([alertView isEqual:self.requestForWaiterAlertView]){
        if([title isEqualToString:@"Yes"])
        {
            NSLog(@"Request For Waiter");
            
            [self requestWithType:@1 WithNote:@"Request For Waiter"];
        }
        else if([title isEqualToString:@"Cancel"])
        {
            NSLog(@"Request For waiter Canceled");
        }else{
            NSLog(@"Unrecognized button pressed");
        }
    }
    
    else if ([alertView isEqual:self.inputTableIDAlertView]){

        if(![title isEqualToString:@"Cancel"])
        {

            NSString *inputCodeFromDiner = [alertView textFieldAtIndex:0].text;
            
            for (NSString *validTableCode in [self.validTableIDs allKeys]) {
                NSLog(@"%@", validTableCode);
                if ([[inputCodeFromDiner lowercaseString] isEqualToString: validTableCode]) {
                    NSLog(@"The table ID is valid");
                    self.tableID = [[self.validTableIDs objectForKey:validTableCode] integerValue];
                    self.taskAfterAskingForTableID();
                    [[Mixpanel sharedInstance].people increment:@"Number of Visit(key in table code)" by:[NSNumber numberWithInt:1]];
                    return;
                }
            }
            [self askForTableIDWithTitle:@"Table ID incorrect. Please enter your table ID or ask your friendly waiter for assistance"];
        }
    }
    
    else if ([alertView isEqual:self.placeOrderAlertView]){
        
        NSLog(@"Place Order Alert View Clicked");
    
        if(![title isEqualToString:@"Cancel"])
        {
            [self performPlaceOrderNetWorkRequest];
        }
        
    }
    
    else if ([alertView isEqual:self.goBackButtonPressedAlertView]){
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    else{
        NSLog(@"In alertView delegateion method: No alertview found.");
    }
}

- (void) dishOrdered:(Dish *)dish{
    [self.userInfo.currentOrder addDish:dish];
    [self updateItemQuantityBadge];
}

- (void) orderQuantityHasChanged:(Order *)order{
    NSLog(@"MenuViewController Detected Order Change");
    [self updateItemQuantityBadge];
}

- (void) updateItemQuantityBadge{
    
    int totalQuantity = [self.userInfo.currentOrder getTotalQuantity];
    
    if (totalQuantity == 0) {
        [self.itemQuantityLabel setHidden:YES];
        [self.itemQuantityLabelBackgroundImageView setHidden:YES];
    } else{
        [self.itemQuantityLabel setHidden:NO];
        [self.itemQuantityLabelBackgroundImageView setHidden:NO];
        self.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", totalQuantity];
        
        // Animation of the red badge:
       [BigSpoonAnimationController animateBadgeAfterUpdate: self.itemQuantityLabelBackgroundImageView
                                          withOriginalFrame: oldFrameItemBadge];
    }
}

- (void)setValidTableIDs: (NSDictionary *)vIDs{
    [[NSUserDefaults standardUserDefaults] setObject: vIDs forKey: [NSString stringWithFormat:@"%@%d",OUTLET_ID_PREFIX ,self.outlet.outletID]];
    _validTableIDs = vIDs;
}

- (NSDictionary *)validTableIDs {
    if (_validTableIDs){
        return _validTableIDs;
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey: [NSString stringWithFormat:@"%@%d",OUTLET_ID_PREFIX ,self.outlet.outletID]];
}

- (void)displayModeDidChange{
    [self toggleDisplayModeAndReloadData];
}

// PlaceOrderDelegate:
- (Order *) addDishWithID: (int) dishID{
    // require: in item page
    
    [self.userInfo.currentOrder incrementDishWithId:dishID];
    [self updateItemQuantityBadge];
    return self.userInfo.currentOrder;
}

- (Order *) minusDishWithID: (int) dishID{
    // require: in item page
    
    [self.userInfo.currentOrder decrementDishWithId:dishID];
    [self updateItemQuantityBadge];
    return self.userInfo.currentOrder;
}

- (Order *) addNote: (NSString*)note toDish: (Dish *)dish {
    [self.userInfo.currentOrder addNote:note forDish:dish];
    return self.userInfo.currentOrder;
}

- (void) placeOrderWithNotes:(NSString *)notes{
    
    // If the user hasn't ordered anything:
    if ([self.userInfo.currentOrder getTotalQuantity] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Place Order"
                                  message:@"You haven't selected anything."
                                  delegate:nil
                                  cancelButtonTitle:@"Okay"
                                  otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    NSLog(@"Placing order");
    
    notesWhenPlacingOrder = notes;
    
    if (![self isTableIDKnown]) {
        [self askForTableID];
         [[Mixpanel sharedInstance] track:@"MenuView: Order placed(Not verified)"];
        __weak MenuViewController *weakSelf = self;
        
        self.taskAfterAskingForTableID = ^(void){
            [weakSelf showPlaceOrderConfirmationPopUp];
        };
    } else{
        [[Mixpanel sharedInstance] track:@"MenuView: Order placed"];
        [self showPlaceOrderConfirmationPopUp];
    }
}


- (void) showPlaceOrderConfirmationPopUp {
    // Here we need to pass a full frame
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createConfirmOrderViewContent]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Okay", nil]];
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        if (buttonIndex == 1) {
            [self performPlaceOrderNetWorkRequest];
        }
        [alertView close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];

}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    [alertView close];
}

- (UIView *)createConfirmOrderViewContent
{
    UIScrollView *scrollingViewContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ORDER_ITEM_VIEW_WIDTH, ORDER_CONFIRM_ALERT_MAXIUM_HEIGHT)];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ORDER_ITEM_VIEW_WIDTH, ORDER_CONFIRM_ALERT_TITLE_HEIGHT)];
    titleLabel.text = @"New Order";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont: [UIFont boldSystemFontOfSize:17.0]];
    [scrollingViewContent addSubview:titleLabel];
    
    for(int i = 0, len = [self.userInfo.currentOrder.dishes count]; i < len; i++){
        OrderItemView* itemView = [[OrderItemView alloc] initAtIndex:i];
        Dish* dish = [self.userInfo.currentOrder.dishes objectAtIndex:i];
        itemView.quantityLabel.text = [NSString stringWithFormat:@"%d",[self.userInfo.currentOrder getQuantityOfDishByDish: dish]];
        itemView.dishNameLabel.text = dish.name;
        
        [scrollingViewContent addSubview:itemView];
    }
    
    int currentScollingContentHeight = [self.userInfo.currentOrder.dishes count] * ORDER_ITEM_VIEW_HEIGHT + ORDER_CONFIRM_ALERT_TITLE_HEIGHT;
    
    int alertViewHeight = ORDER_CONFIRM_ALERT_MAXIUM_HEIGHT > currentScollingContentHeight ? currentScollingContentHeight + 20: ORDER_CONFIRM_ALERT_MAXIUM_HEIGHT;
    [scrollingViewContent setFrame:CGRectMake(0,0,scrollingViewContent.frame.size.width, alertViewHeight)];
    [scrollingViewContent setContentSize:CGSizeMake(ORDER_ITEM_VIEW_WIDTH, currentScollingContentHeight + 10)];
    
    return scrollingViewContent;
}

- (void) performPlaceOrderNetWorkRequest{
    
    NSMutableArray *dishesArray = [[NSMutableArray alloc] init];
    
    // For every dish that is currently in the order, we add it to the dishes dictionary:
    for (int i = 0; i < [self.userInfo.currentOrder.dishes count]; i++) {
        Dish *dish = [self.userInfo.currentOrder.dishes objectAtIndex:i];
        NSNumber * quantity = [NSNumber numberWithInt:[self.userInfo.currentOrder getQuantityOfDishByDish: dish]];
        NSString * ID = [NSString stringWithFormat:@"%d", dish.ID];
        
        NSDictionary *newPair = [NSDictionary dictionaryWithObject:quantity forKey:ID];
        [dishesArray addObject:newPair];
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSArray arrayWithArray: dishesArray] forKey:@"dishes"];
    [parameters setObject:[NSNumber numberWithInt: self.tableID] forKey:@"table"];
    if (notesWhenPlacingOrder != nil && ![notesWhenPlacingOrder isEqualToString:@""] ) {
        [parameters setObject:notesWhenPlacingOrder forKey:@"note"];
    }
    
    if (self.userInfo.currentOrder.notes != nil && [self.userInfo.currentOrder.notes count] > 0) {
        [parameters setObject:self.userInfo.currentOrder.notes forKey:@"notes"];
    }

    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: ORDER_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        int responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{
                NSLog(@"Place Order Success");
                [self afterSuccessfulPlacedOrder];
            }
                break;
            case 403:
            default:{
                NSLog(@"Place Order Fail");
                [self displayErrorInfo: operation.responseObject];
            }
        }
        NSLog(@"JSON: %@", responseObject);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Place Order failure: %@", operation.responseString);
        [self displayErrorInfo: operation.responseObject];
    }];
    
    [operation start];
}

- (void) afterSuccessfulPlacedOrder{
    [self.userInfo.pastOrder mergeWithAnotherOrder:self.userInfo.currentOrder];
    self.userInfo.currentOrder = [[Order alloc] init];
    
    User *user = [User sharedInstance];
    user.pastOrder = self.userInfo.pastOrder;
    user.currentOrder = self.userInfo.currentOrder;
    
    [self.itemsOrderedViewController reloadOrderTablesWithCurrentOrder:self.userInfo.currentOrder andPastOrder:self.userInfo.pastOrder];
    
    [self.view makeToast:@"Your order has been sent. Our food is prepared with love, thank you for being patient."
                duration:TOAST_VIEW_DURATION
                position:@"bottom"
                   title:nil];
    
    [self updateItemQuantityBadge];
}

- (Order *) getCurrentOrder{
    return self.userInfo.currentOrder;
}

- (Order *) getPastOrder{
    return self.userInfo.pastOrder;
}

#pragma mark Request For Service (water and waiter)

- (IBAction)plusColdWaterButtonPressed:(id)sender {
    self.quantityOfColdWater++;
    self.quantityOfColdWaterLabel.text = [NSString stringWithFormat:@"%d", quantityOfColdWater];
}

- (IBAction)minusColdWaterButtonPressed:(id)sender {
    if (self.quantityOfColdWater > 0) {
        self.quantityOfColdWater--;
        self.quantityOfColdWaterLabel.text = [NSString stringWithFormat:@"%d", quantityOfColdWater];
    }
}

- (IBAction)plusWarmWaterButtonPressed:(id)sender {
    self.quantityOfWarmWater++;
    self.quantityOfWarmWaterLabel.text = [NSString stringWithFormat:@"%d", quantityOfWarmWater];
}

- (IBAction)minusWarmWaterButtonPressed:(id)sender {
    if (self.quantityOfWarmWater > 0) {
        self.quantityOfWarmWater--;
        self.quantityOfWarmWaterLabel.text = [NSString stringWithFormat:@"%d", quantityOfWarmWater];
    }
}

- (IBAction)requestWaterOkayButtonPressed:(id)sender {
    
    if (self.quantityOfColdWater != 0 || self.quantityOfWarmWater != 0) {
        NSString *note = [NSString stringWithFormat:@"Cold Water: %d cups. Warm Water: %d cups", self.quantityOfColdWater, self.quantityOfWarmWater];
        [self requestWithType:@0 WithNote:note];
    }
    
    [self requestWaterCancelButtonPressed:nil];
    [TestFlight passCheckpoint:@"CheckPoint:User Asking for water"];
}

- (void) requestWithType: (id) requestType WithNote: (NSString *)note{
    NSDictionary *parameters = @{
                                 @"table": [NSNumber numberWithInt: self.tableID],
                                 @"request_type": requestType,
                                 @"note": note
                                 };
    
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: REQUEST_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        int responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{

                [self.view makeToast:@"The waiter will be right with you"
                            duration:TOAST_VIEW_DURATION
                            position:@"bottom"
                               title:nil];
            }
                break;
            case 403:
            default:{
                [self displayErrorInfo: operation.responseObject];
            }
        }
        NSLog(@"JSON: %@", responseObject);
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [self displayErrorInfo:operation.responseObject];
                                      }];
    [operation start];
}

- (void) displayErrorInfo: (id) responseObject{
    
    NSDictionary *dictionary = (NSDictionary *)responseObject;
    
    NSMutableString *message = [[NSMutableString alloc] init];
    
    NSArray *errorInfoArray= [dictionary allValues];
    
    for (NSString * errorInfo in errorInfoArray) {
        [message appendString:errorInfo];
    }

    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Oops"
                              message: message
                              delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)requestWaterCancelButtonPressed:(id)sender {

    self.quantityOfWarmWater = 0;
    self.quantityOfColdWater = 0;
    self.quantityOfWarmWaterLabel.text = [NSString stringWithFormat:@"%d", self.quantityOfWarmWater];
    self.quantityOfColdWaterLabel.text = [NSString stringWithFormat:@"%d", self.quantityOfColdWater];
    
    [BigSpoonAnimationController animateTransitionOfUIView:self.requestWaterView willShow:NO];
}

#pragma mark - Dealing with table number

- (BOOL) isTableIDKnown{
    NSLog(@"Current table ID: %d", self.tableID);
    // If tableID is 0 or -1, we conclude that the tableID is not known from the user.
    return self.tableID > 0;
}

- (void) askForTableID{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:ENABLE_LOCATION_ALERT_TITLE message: ENABLE_LOCATION_ALERT delegate:nil cancelButtonTitle:@"OK"                            otherButtonTitles:nil];
        [errorAlert show];
        [TestFlight passCheckpoint:@"CheckPoint:User Location not enabled"];
        return;
    }
    
    if ([User sharedInstance].locationAvailableForChecking && ![self isUserLocation:[User sharedInstance].userLocation WithinMeters:LOCATION_CHECKING_DIAMETER OfLatitude:self.outlet.lat AndLongitude:self.outlet.lon]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle: CANNOT_DETECT_LOCATION_ALERT_TITLE message:CANNOT_DETECT_LOCATION_ALERT delegate:nil cancelButtonTitle:@"OK"                            otherButtonTitles:nil];
        [TestFlight passCheckpoint:@"CheckPoint:User Action outside restaurant"];
        [errorAlert show];
    } else {
        [self askForTableIDWithTitle: @"Please enter your table ID located on the BigSpoon table stand"];
        [TestFlight passCheckpoint:@"CheckPoint:User Action inside restaurant"];
    }
}

- (void) askForTableIDWithTitle: (NSString *)title{
    self.inputTableIDAlertView = [[UIAlertView alloc]
                              initWithTitle: title
                              message: nil
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Okay", nil];

    self.inputTableIDAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.inputTableIDAlertView show];
}

#pragma mark - Others

// @param: width and height of a view
// @return: the frame if the view is located at the center of the screen
- (CGRect) getFrameAtCenterOfScreenWithWidth: (int) viewWidth andHeight: (int) viewHeight{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    
    
    return CGRectMake(screenWidth / 2 - viewWidth / 2,
                      screenHeight / 2 - viewHeight / 2,
                      viewWidth,
                      viewHeight);
}


@end
