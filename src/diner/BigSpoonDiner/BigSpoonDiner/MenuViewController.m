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
}

- (IBAction)requestForWaterButtonPressed:(id)sender {
    NSLog(@"requestForWaterButtonPressed");

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

- (IBAction)breakfastButtonPressed:(id)sender {
    NSLog(@"breakfastButtonPressed");

}

- (IBAction)mainButtonPressed:(id)sender {
    NSLog(@"mainButtonPressed");

}

- (IBAction)sideButtonPressed:(id)sender {
    NSLog(@"sideButtonPressed");

}

- (IBAction)beverageButtonPressed:(id)sender {
    NSLog(@"beverageButtonPressed");

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
    if ([segue.identifier isEqualToString:@"FromMenuListToOrderHistory"]) {
		OrderHistoryViewController *orderHistoryViewController = segue.destinationViewController;
		orderHistoryViewController.delegate = self;
        
	} else{
        NSLog(@"Segure in the outletsViewController cannot assign delegate to its segue");
    }
}

- (void) cancelButtonPressed:(OrderHistoryViewController *)controller{
    NSLog(@"cancelled");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
