//
//  MenuViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@property (nonatomic, strong) UIAlertView *requestForWaiterView;
@property (nonatomic, strong) UIAlertView *requestForBillView;
@property (nonatomic, strong) UIAlertView *inputTableIDView;

@end

@implementation MenuViewController

@synthesize delegate;
@synthesize outlet;
@synthesize menuListViewController;
@synthesize requestWaterView;

@synthesize quantityOfColdWater;
@synthesize quantityOfWarmWater;

@synthesize quantityOfColdWaterLabel;
@synthesize quantityOfWarmWaterLabel;
@synthesize requestForWaiterView;
@synthesize requestForBillView;
@synthesize ratingsTableView;

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
    //MenuTableViewController *menuTableViewController = [self.container ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ButtonClick Event Listeners


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
    [self askForTableID];
    NSLog(@"requestForWaterButtonPressed");
    [self animateControlPanelView:self.requestWaterView willShow:YES];
}

- (IBAction)callWaiterButtonPressed:(id)sender {
    NSLog(@"callWaiterButtonPressed");
    self.requestForWaiterView = [[UIAlertView alloc]
                              initWithTitle:@"Call For Service"
                              message:@"Require assistance from the waiter?"
                              delegate:self
                              cancelButtonTitle:@"Yes"
                              otherButtonTitles:@"Cancel", nil];
    [self.requestForWaiterView show];
}

- (IBAction)billButtonPressed:(id)sender {
    NSLog(@"billButtonPressed");
    NSLog(@"callWaiterButtonPressed");
    self.requestForBillView = [[UIAlertView alloc]
                                 initWithTitle:@"Call For Service"
                               message:@"Would you like the bill?"
                                 delegate:self
                                 cancelButtonTitle:@"Yes"
                                 otherButtonTitles:@"Cancel", nil];
    [self.requestForBillView show];
}

- (IBAction)itemsButtonPressed:(id)sender {
    NSLog(@"itemsButtonPressed");

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

#pragma mark Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([alertView isEqual:self.requestForBillView]) {
        if([title isEqualToString:@"Yes"])
        {
            NSLog(@"Request For Bill");
            // TODO Make HTTP request for this.
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Call For Service"
                                      message:@"The waiter will be right with you"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            
            //[self animateControlPanelView:self.ratingsView willShow:YES];
        }
        else if([title isEqualToString:@"Cancel"])
        {
            NSLog(@"Request For bill Canceled");
        }else{
            NSLog(@"Unrecognized button pressed");
        }
    } else if ([alertView isEqual:self.requestForWaiterView]){
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
}

- (void) DishOrdered:(Dish *)dish{
    NSLog(@"New Dish Ordered!");
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
    
    NSString *note = [NSString stringWithFormat:@"Cold Water: %d cups. Warm Water: %d cups", self.quantityOfColdWater, self.quantityOfWarmWater];

    [self requestWithType:@0 WithNote:note];
    
    [self requestWaterCancelButtonPressed:nil];
}

- (void) requestWithType: (id) requestType WithNote: (NSString *)note{
    NSDictionary *parameters = @{
                                 @"table": @2,
                                 @"request_type": requestType,
                                 @"note": note
                                 };
    
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: REQUEST_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.auth_token] forHTTPHeaderField: @"Authorization"];
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
                NSLog(@"Success");
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Call For Service"
                                          message:@"The waiter will be right with you"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
                break;
            case 403:
            default:{
                [self displayErrorInfo: @"Please check your network"];
            }
        }
        NSLog(@"JSON: %@", responseObject);
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [self displayErrorInfo:operation.responseString];
                                      }];
    [operation start];
}

- (void) displayErrorInfo: (NSString *) info{
    NSLog(@"Error: %@", info);
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Oops"
                              message: info
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)requestWaterCancelButtonPressed:(id)sender {

    self.quantityOfWarmWater = 0;
    self.quantityOfColdWater = 0;
    self.quantityOfWarmWaterLabel.text = [NSString stringWithFormat:@"%d", self.quantityOfWarmWater];
    self.quantityOfColdWaterLabel.text = [NSString stringWithFormat:@"%d", self.quantityOfColdWater];
    
    [self animateControlPanelView:self.requestWaterView willShow:NO];
}

#pragma mark Request for Bill

- (IBAction)ratingSubmitButtonPressed:(id)sender {
    
    [self ratingCancelButtonPressed:nil];
}

- (IBAction)ratingCancelButtonPressed:(id)sender {
    [self animateControlPanelView:self.ratingsView willShow:NO];
}

#pragma makr Animation

- (void) animateControlPanelView: (UIView *)view willShow: (BOOL) willShow{
    
    // view.alpha: how transparent it is. If 0, it still occupy its space on the screen
    // view.hidden: whether it is shown. If no, it will not occupy its space on the screen
    
    // Set the alpha to the other way. And set it back in the animation.
    if (willShow) {
        view.alpha = 0;
    } else{
        view.alpha = 1;
    }
    
    if (willShow) {
        [view setHidden: !willShow];
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         if (willShow) {
                             view.alpha = 1;
                         } else{
                             view.alpha = 0;
                         }
                     }
                     completion:^(BOOL finished){
                         if (!willShow) {
                             [view setHidden: !willShow];
                         }
                     }];
}

#pragma mark Ask For Table Number

- (void) askForTableID{
    return;
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Please enter your table ID"
                              message: nil
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView show];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return NO;
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"hshsa");
}



@end
