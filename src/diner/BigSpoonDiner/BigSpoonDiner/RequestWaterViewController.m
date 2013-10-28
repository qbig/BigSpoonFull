//
//  RequestWaterViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 28/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RequestWaterViewController.h"

@interface RequestWaterViewController ()

@end

@implementation RequestWaterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"initialized");

    }
    return self;
}

- (void)loadView{
    [super loadView];
    NSLog(@"loadview");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)plusColdWaterPressed:(id)sender {
}

- (IBAction)minusColdWaterPressed:(id)sender {
}

- (IBAction)plusWarmWaterPressed:(id)sender {
}

- (IBAction)minusWarmWaterPressed:(id)sender {
}

- (IBAction)okayButtonPressed:(id)sender {
}

- (IBAction)cancelButtonPressed:(id)sender {
}
@end
