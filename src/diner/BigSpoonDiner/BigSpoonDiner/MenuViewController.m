//
//  MenuViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize delegate;
@synthesize outlet;
@synthesize menuListViewController;
@synthesize requestWaterViewController;

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
    self.outletNameLabel.text = self.outlet.name;
    self.requestWaterViewController = [[RequestWaterViewController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)homeButtonPressed:(id)sender{
    [self.delegate MenuViewControllerHomeButtonPressed:self];
}

- (IBAction)viewModeButtonPressed:(id)sender {
    NSLog(@"viewModeButtonPressed");
    if (self.menuListViewController.displayMethod == kMethodList){
        self.menuListViewController.displayMethod = kMethodPhoto;
        [self.viewModeButton setImage:[UIImage imageNamed:@"photo_icon.png"] forState:UIControlStateHighlighted];
        [self.viewModeButton setImage:[UIImage imageNamed:@"photo_icon.png"] forState:UIControlStateNormal];

    } else{
        self.menuListViewController.displayMethod = kMethodList;
        [self.viewModeButton setImage:[UIImage imageNamed:@"list_icon.png"] forState:UIControlStateHighlighted];
        [self.viewModeButton setImage:[UIImage imageNamed:@"list_icon.png"] forState:UIControlStateNormal];
    }
    [self.menuListViewController.tableView reloadData];
}

- (IBAction)requestForWaterButtonPressed:(id)sender {
    NSLog(@"requestForWaterButtonPressed");
    
    [self.view addSubview: self.requestWaterViewController.controlPanelView];
     
    
    return;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    User *user = [User sharedInstance];
    
    NSDictionary *parameters = @{
                                 @"token": user.auth_token,
                                 @"table_id": @"3",
                                 @"request_type": @"0"
                                 };
    [manager POST:REQUEST_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:{
                NSLog(@"Success");
                
            }
                break;
            case 403:{
                NSLog(@"Authentication credentials were not provided.");
            }
            default:
                break;
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (IBAction)callWaiterButtonPressed:(id)sender {
    NSLog(@"callWaiterButtonPressed");

}

- (IBAction)billButtonPressed:(id)sender {
    NSLog(@"billButtonPressed");

}

- (IBAction)itemsButtonPressed:(id)sender {
    NSLog(@"itemsButtonPressed");

}

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
		OrderHistoryViewController *orderHistoryViewController = segue.destinationViewController;
		orderHistoryViewController.delegate = self;
        
	} else if ([segue.identifier isEqualToString:@"SegueFromContainerToDishList"]){
        self.menuListViewController = segue.destinationViewController;
        self.menuListViewController.outlet = self.outlet;
        self.menuListViewController.delegate = self;
    } else{
        NSLog(@"Segure in the menuViewController cannot assign delegate to its segue. Segue identifier: %@", segue.identifier);
    }
}

- (void) cancelButtonPressed:(OrderHistoryViewController *)controller{
    NSLog(@"cancelled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Delegate:

- (void) DishOrdered:(Dish *)dish{
    NSLog(@"New Dish Ordered!");
}

@end
