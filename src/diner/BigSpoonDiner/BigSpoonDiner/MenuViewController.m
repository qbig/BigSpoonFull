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
@end
