//
//  OutletsViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "OutletsTableViewController.h"
#import "UIColor+ColorFromHex.h"
@interface OutletsTableViewController (){
    NSMutableData *_responseData;
    int statusCode;
    CLLocationManager* locationManager;
    NSString* messageFromMenuPage;
    NSDictionary *jsonForMenuView;
    UIActivityIndicatorView *indicator;
}
@property (nonatomic,strong) UIColor *bigSpoonOrange;
@end

@implementation OutletsTableViewController

@synthesize outletsArray;
@synthesize outletsTableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)setNavbarColorAndFont
{
    // set navbar background color
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = self.bigSpoonOrange;
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = self.bigSpoonOrange;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = NO;
    }
    
    // set title font
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"ProximaNova-Bold" size:18] forKey:NSFontAttributeName];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationController.navigationBar setTitleTextAttributes: titleBarAttributes];
    
    // set status bar text color
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)connectToSocket
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate connectSocket];
}

- (void)setUpTracking
{
    [[Mixpanel sharedInstance] track:@"OutletView: User at Outlet View"];
    [[Mixpanel sharedInstance].people increment:@"Reach Outlet View" by: [NSNumber numberWithInt:1]];
    [TestFlight passCheckpoint:@"CheckPoint:User Checking Outlets list"];
}

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [self setUpTracking];
    [super viewDidLoad];
    [self initActivityIndicator];
    [self showLoadingIndicators];
    [self loadOutletsFromServer];
    [self connectToSocket];
    self.outletsTableView.allowsSelection = YES;
    self.bigSpoonOrange = [UIColor colorFromHexString:@"#FF6235"];
    [self setNavbarColorAndFont];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // The "bottom" is not precise
    // Need to set the position manually:
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    if (messageFromMenuPage != nil && ![messageFromMenuPage isEqualToString:@""]) {
        [self.view makeToast:messageFromMenuPage
                    duration:TOAST_VIEW_DURATION
                    position:[NSValue valueWithCGPoint:CGPointMake(screenWidth / 2, screenHeight - 110)]
                       title:nil];
    }
    [self filterOutletListBasedOnLocation];
    [self reorderOutletListBasedOnLocation];
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToCategorieView:) name:NOTIF_NEW_DISH_INFO_RETRIEVED object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.outletsArray count];
}

// hack to set tableview separator
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OutletCell *cell = (OutletCell *)[tableView dequeueReusableCellWithIdentifier:@"OutletCell"];
	Outlet *outlet = [self.outletsArray objectAtIndex:indexPath.row];
    [cell.outletPhoto setImageWithURL:outlet.imgURL placeholderImage:[UIImage imageNamed:@"white315_203.gif"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	cell.name.text = outlet.name;
	cell.address.text = outlet.address;
	cell.phoneNumber.text = outlet.phoneNumber;
	cell.operatingHours.text = outlet.operatingHours;
    cell.promotionTextLabel.text = outlet.promotionalText;
    
    if (indexPath.row == 0){
        cell.layer.borderColor = self.bigSpoonOrange.CGColor;
        cell.layer.borderWidth = 3.0f;
    } else {
        cell.layer.borderWidth = 0;
    }

    return cell;
}

#warning refactor this with something like Mantle

- (void) loadOutletsFromServer{
    
    NSLog(@"Loading outlets from server...");
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LIST_OUTLETS]];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         long responseCode = [operation.response statusCode];
         switch (responseCode) {
             case 200:
             case 201:{
                 NSArray* outletList = (NSArray*) responseObject;
                 self.outletsArray = [[NSMutableArray alloc] initWithCapacity:[outletList count]];
                 for (NSDictionary *newOutlet in outletList) {
                     NSDictionary *restaurant = (NSDictionary *)[newOutlet objectForKey:@"restaurant"];
                     NSDictionary *icon = (NSDictionary *)[restaurant objectForKey:@"icon"];
                     NSString *thumbnail = (NSString *)[icon objectForKey:@"thumbnail"];
                     NSURL *imgURL = [[NSURL alloc] initWithString:[BASE_URL stringByAppendingString:thumbnail]];
                     
                     int ID = [[newOutlet objectForKey:@"id"] intValue];
                     double lat = [[newOutlet objectForKey:@"lat"] doubleValue];
                     double lon = [[newOutlet objectForKey:@"lng"] doubleValue];
                     NSString* name = [newOutlet objectForKey:@"name"];
                     NSString* phone = [newOutlet objectForKey:@"phone"];
                     NSString* address = [newOutlet objectForKey:@"address"];
                     NSString* opening = [newOutlet objectForKey:@"opening"];
                     NSString* promotionalText = [newOutlet objectForKey:@"discount"];
                     NSString* defaultDishPhotoUrl = [newOutlet objectForKey:@"default_dish_photo"];
                     double gstRate = [[newOutlet objectForKey:@"gst"] doubleValue];
                     double serviceChargeRate = [[newOutlet objectForKey:@"scr"] doubleValue];
                     BOOL isActive = (BOOL)[[newOutlet objectForKey:@"is_active"] boolValue];
                     BOOL isDefaultPhotoMenu = (BOOL)[[newOutlet objectForKey:@"is_by_default_photo_menu"] boolValue];
                     BOOL requestForWaterEnabled = (BOOL)[[newOutlet objectForKey:@"request_for_water_enabled"] boolValue];
                     NSString *waterText = [newOutlet objectForKey:@"water_popup_text"];
                     BOOL isRequestForBillEnabled = (BOOL)[[newOutlet objectForKey:@"ask_for_bill_enabled"] boolValue];
                     NSString *billText = [newOutlet objectForKey:@"bill_popup_text"];
                     double locationDiameter = [[newOutlet objectForKey: @"location_diameter"] doubleValue];
                     if (!isActive) {
                         promotionalText = @"Coming Soon!";
                     }
                     
                     NSLog(@"Outlet id: %d, lat: %f, lon: %f", ID, lat, lon);
                     
                     Outlet *newOutletObject = [[Outlet alloc]initWithImgURL: imgURL
                                                                        Name: name
                                                                     Address: address
                                                                 PhoneNumber: phone
                                                             OperationgHours: opening
                                                            defaultDishPhoto: defaultDishPhotoUrl
                                                                    OutletID: ID
                                                                         lat: lat
                                                                         lon: lon
                                                             promotionalText: promotionalText
                                                                     gstRate: gstRate
                                                           serviceChargeRate: serviceChargeRate
                                                                    isActive: isActive
                                                                 isPhotoMenu: isDefaultPhotoMenu
                                                    isRequestForWaterEnabled: requestForWaterEnabled
                                                                   waterText: waterText
                                                     isRequestForBillEnabled: isRequestForBillEnabled
                                                                    billText: billText
                                                           locationThreshold: locationDiameter];
                     [self.outletsArray addObject:newOutletObject];
                 }
                 
                 [self filterOutletListBasedOnLocation];
                 [self reorderOutletListBasedOnLocation];
                 [self.tableView reloadData];
                 [self stopLoadingIndicators];
             }
                 break;
             case 403:
             default:{
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEW_DISH_INFO_FAILED object:nil];
             }
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEW_DISH_INFO_FAILED object:nil];
     }];
    [operation start];
}

- (void) reorderOutletListBasedOnLocation {
    if(self.outletsArray && [User sharedInstance].userLocation){
        self.outletsArray = [[self.outletsArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            double firstDist = [(Outlet*)a distanceFrom: [User sharedInstance].userLocation];
            double secondDist = [(Outlet*)b distanceFrom: [User sharedInstance].userLocation];
            return firstDist >= secondDist;
        }] mutableCopy];
    }
}

- (void) filterOutletListBasedOnLocation {
    if(self.outletsArray && [User sharedInstance].userLocation){
        self.outletsArray = [[self.outletsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            return [(Outlet*) object distanceFrom: [User sharedInstance].userLocation] <= LOCATION_FILTER_DISTANCE_100KM ;
        }]] mutableCopy];
    }
}

- (void)MenuViewControllerHomeButtonPressed: (MenuViewController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied){
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"Location Enabled" : @"Yes"}];
    } else {
        [[Mixpanel sharedInstance] registerSuperProperties:@{@"Location Enabled" : @"No"}];
    }
    Outlet *outlet = [self.outletsArray objectAtIndex:indexPath.row];
    
    if ([indicator isAnimating]){
        return;
    }
    [[Mixpanel sharedInstance] track: [NSString stringWithFormat: @"OutletView: Clicked outlet: %@",outlet.name]];
    if (outlet.isActive) {
        NSLog(@"Row: %d, ID: %d", (int) indexPath.row, outlet.outletID);
        // load data for selected outlet
        [[User sharedInstance] loadDishesAndTableInfosFromServerForOutlet: outlet.outletID];
        [User sharedInstance].currentLoadedOutlet = outlet;
        [[User sharedInstance].currentSession switchToOutlet:outlet.name];
        [indicator startAnimating];
    } else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"The restaurant is coming soon"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

- (void) moveToMenuView: (NSNotification*) notif{
    [indicator stopAnimating];
    jsonForMenuView = (NSDictionary* )[notif object];
    [self performSegueWithIdentifier:@"SegueFromOutletsToMenu" sender:self];
}

- (void) moveToCategorieView: (NSNotification*) notif{
    [indicator stopAnimating];
    jsonForMenuView = (NSDictionary* )[notif object];
    [self performSegueWithIdentifier:@"SegueFromOutletsToCategories" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueFromOutletsToMenu"]) {
		MenuViewController *menuViewController = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Outlet *selectedOutlet = [self.outletsArray objectAtIndex:selectedIndexPath.row];
        menuViewController.outlet = selectedOutlet;
        menuViewController.delegate = self;
        menuViewController.jsonForDishesTablesAndCategories = jsonForMenuView;
        if (selectedOutlet.outletID == self.outletIDOfPreviousSelection) {
            // Assign the history to the outlet:
            [User sharedInstance].tableID = self.tableIDOfPreviousSelection;
            self.tableIDOfPreviousSelection = -1;
            self.outletIDOfPreviousSelection = -1;
        } else{
            NSLog(@"In outlets list: opening a new page with no selected items");
        }
        
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStyleBordered target: nil action: nil];
        [[self navigationItem] setBackBarButtonItem: newBackButton];
        
    } else if ([segue.identifier isEqualToString:@"SegueFromOutletsToCategories"]) {
        CategoriesTableViewController *categoriesViewController = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Outlet *selectedOutlet = [self.outletsArray objectAtIndex:selectedIndexPath.row];
        categoriesViewController.outlet = selectedOutlet;
        categoriesViewController.delegate = self;
        categoriesViewController.jsonForDishesTablesAndCategories = jsonForMenuView;
        if (selectedOutlet.outletID == self.outletIDOfPreviousSelection) {
            // Assign the history to the outlet:
            [User sharedInstance].tableID = self.tableIDOfPreviousSelection;
            self.tableIDOfPreviousSelection = -1;
            self.outletIDOfPreviousSelection = -1;
        } else{
            NSLog(@"In outlets list: opening a new page with no selected items");
        }
        
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStyleBordered target: nil action: nil];
        [[self navigationItem] setBackBarButtonItem: newBackButton];
    } else{
        NSLog(@"Segureee in the outletsViewController cannot assign delegate to its segue. Segue identifier: %@", segue.identifier);
    }
}

#pragma mark - Delegate

- (void) exitMenuListWithCurrentOrder: (Order *) currentOrder
                            PastOrder: (Order *) pastOrder
                             OutletID: (int) outletID
                           andTableID: (int) tableID
                           andMessage: (NSString *)message{
    
    self.outletIDOfPreviousSelection = outletID;
    self.tableIDOfPreviousSelection = tableID;
    messageFromMenuPage = message;
}

#pragma mark Show and hide indicators
- (void)initActivityIndicator
{
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

- (void) showLoadingIndicators{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
    [self.tableView setUserInteractionEnabled:NO];
}

- (void) stopLoadingIndicators{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [indicator stopAnimating];
    [self.tableView setUserInteractionEnabled:YES];
}

- (IBAction)logoutButtonPressed:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilePhotoURL"];
    [SSKeychain deletePasswordForService:@"BigSpoon" account:[User sharedInstance].email];
    User *user = [User sharedInstance];
    [user.currentSession clearCurrentOrder];
    [user.currentSession clearPastOrder];
    user.currentLoadedOutlet = nil;
    user.validTableIDs = nil;
    [self dismissViewControllerAnimated:YES completion:nil];

    // disconnect socket
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate disconnectSocket];
}
@end
