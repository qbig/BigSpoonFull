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
#import "MultiContainerViewSegue.h"
#import "Order.h"

@class MenuViewController;

@protocol MenuViewControllerDelegate <NSObject>
- (void)MenuViewControllerHomeButtonPressed: (MenuViewController *)controller;
@end


@interface MenuViewController : UIViewController <OrderDishDelegate, SettingsViewControllerDelegate, UITextFieldDelegate, NSURLConnectionDelegate>

// Data:
@property (nonatomic, weak) id <MenuViewControllerDelegate> delegate;
@property (nonatomic, strong) Outlet *outlet;
@property (nonatomic) int tableID;
@property (nonatomic) NSArray *validTableIDs;
@property (nonatomic, strong) Order *order;

// Buttons:

@property (strong, nonatomic) IBOutlet UIButton *viewModeButton;
@property (strong, nonatomic) IBOutlet UILabel *outletNameLabel;

// Three buttons at the top: (gear button no need here)

- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)viewModeButtonPressedAtListPage:(id)sender;
- (IBAction)viewModeButtonPressedAtOrderPage:(id)sender;

// Four buttons at the bottom

- (IBAction)requestWaterButtonPressed:(id)sender;
- (IBAction)requestWaiterButtonPressed:(id)sender;
- (IBAction)requestBillButtonPressed:(id)sender;
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
@property (strong, nonatomic) IBOutlet UITextField *feedbackTextField;
- (IBAction)ratingSubmitButtonPressed:(id)sender;
- (IBAction)ratingCancelButtonPressed:(id)sender;

// For container view:
@property (weak,nonatomic) UIViewController *destinationViewController;
@property (strong, nonatomic) NSString *destinationIdentifier;
@property (strong, nonatomic) UIViewController *oldViewController;

// For the item quantity label:
@property (strong, nonatomic) IBOutlet UILabel *itemQuantityLabel;
@property (strong, nonatomic) IBOutlet UIImageView *itemQuantityLabelBackgroundImageView;


@end
