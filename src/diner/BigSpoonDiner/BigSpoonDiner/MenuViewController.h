//
//  MenuViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Outlet.h"
#import "OrderHistoryViewController.h"
#import "MenuTableViewController.h"
#import <AFHTTPRequestOperationManager.h>
#import "User.h"
#import "Constants.h"

@class MenuViewController;

@protocol MenuViewControllerDelegate <NSObject>
- (void)MenuViewControllerHomeButtonPressed: (MenuViewController *)controller;
@end


@interface MenuViewController : UIViewController <OrderDishDelegate, SettingsViewControllerDelegate, NSURLConnectionDelegate>


@property (nonatomic, weak) id <MenuViewControllerDelegate> delegate;
@property (nonatomic, strong) Outlet *outlet;

// Buttons:

@property (strong, nonatomic) IBOutlet UIButton *viewModeButton;
@property (strong, nonatomic) IBOutlet UILabel *outletNameLabel;

// Three buttons at the top: (gear button no need here)

- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)viewModeButtonPressed:(id)sender;

// Four buttons at the bottom

- (IBAction)requestForWaterButtonPressed:(id)sender;
- (IBAction)callWaiterButtonPressed:(id)sender;
- (IBAction)billButtonPressed:(id)sender;
- (IBAction)itemsButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) MenuTableViewController *menuListViewController;


// "Call For Service" Control Panel:
@property (strong, nonatomic) IBOutlet UIView *requestWaterView;

@property (nonatomic) int quantityOfColdWater;
@property (nonatomic) int quantityOfWarmWater;

@property (strong, nonatomic) IBOutlet UILabel *quantityOfColdWaterLabel;
@property (strong, nonatomic) IBOutlet UILabel *quantityOfWarmWaterLabel;

- (IBAction)plusColdWaterButtonPressed:(id)sender;
- (IBAction)minusColdWaterButtonPressed:(id)sender;

- (IBAction)plusWarmWaterButtonPressed:(id)sender;
- (IBAction)minusWarmWaterButtonPressed:(id)sender;

- (IBAction)requestWaterOkayButtonPressed:(id)sender;
- (IBAction)requestWaterCancelButtonPressed:(id)sender;

// "Bill" Control Panel:
@property (strong, nonatomic) IBOutlet UIView *ratingsView;
@property (strong, nonatomic) IBOutlet UITableView *ratingsTableView;
@property (strong, nonatomic) IBOutlet UITextView *feedbackTextView;

- (IBAction)ratingSubmitButtonPressed:(id)sender;
- (IBAction)ratingCancelButtonPressed:(id)sender;

@end
