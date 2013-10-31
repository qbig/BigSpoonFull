//
//  ProfileViewController.m
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 27/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"HomeAndSettingsButtonView" owner:self options:nil];
    self.topRightButtonsView = [subviewArray objectAtIndex:0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.topRightButtonsView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
