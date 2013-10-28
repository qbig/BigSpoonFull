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

@end
