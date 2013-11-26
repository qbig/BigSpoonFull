//
//  PastOrderDetailViewController.m
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 19/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "PastOrderDetailViewController.h"

@interface PastOrderDetailViewController ()

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
    NSLog(@"I am here");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.meals count];
    NSLog(@"I am here");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mealItem"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:101];
    lblName.text = @"Works";
//    [lblName setText:[self.meals[[indexPath row]] objectAtIndex:[indexPath row]]];
    return cell;
}


@end
