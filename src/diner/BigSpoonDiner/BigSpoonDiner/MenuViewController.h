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
#import "ItemsOrderedViewController.h"
#import "ExitMenuListDelegate.h"
#import "RatingAndFeedbackViewController.h"
#import "BigSpoonAnimationController.h"
#import "CustomIOS7AlertView.h"
#import "OrderItemView.h"
#import "ModalSegueDelegate.h"
#import "SubmitRatingAndFeedbackSuccessDelegate.h"

@class MenuViewController;

@interface MenuViewController : UIViewController <OrderDishDelegate, UITextFieldDelegate, NSURLConnectionDelegate,PlaceOrderDelegate, CustomIOS7AlertViewDelegate, MenuDisplayModeDelegate, ModalSegueDelegate, SubmitRatingAndFeedbackSuccessDelegate>

// Data:
@property (nonatomic, strong) Outlet *outlet;
@property (nonatomic) NSDictionary *validTableIDs;
@property (strong, nonatomic) User* userInfo;
@property (nonatomic, weak) id <ExitMenuListDelegate> delegate;
@property (nonatomic, strong) NSDictionary *jsonForDishesTablesAndCategories;
// Buttons:

@property (strong, nonatomic) IBOutlet UIButton *viewModeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *viewModeBarButton;

@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButton;

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

- (IBAction)viewModeButtonPressedAtListPage:(id)sender;
- (IBAction)viewModeButtonPressedAtOrderPage:(id)sender;
- (IBAction)settingsButtonPressed:(id)sender;
- (void)modalSegueDidExit;

// Four buttons at the bottom

- (IBAction)requestWaterButtonPressed:(id)sender;
- (IBAction)requestWaiterButtonPressed:(id)sender;
- (IBAction)requestBillButtonPressed:(id)sender;
- (IBAction)itemsButtonPressed:(id)sender;

// Cover views. For animation purpost. When the buttons are clicked, the views will blank.
@property (strong, nonatomic) IBOutlet UIView *requestWaterButtonCoverView;
@property (strong, nonatomic) IBOutlet UIView *requestWaiterButtonCoverView;
@property (strong, nonatomic) IBOutlet UIView *requestBillButtonCoverView;
@property (strong, nonatomic) IBOutlet UIView *itemsButtonCoverView;


// Objects related to Container view:

@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) MenuTableViewController *menuListViewController;
@property (strong, nonatomic) ItemsOrderedViewController *itemsOrderedViewController;

/*
 * "Call For Service" Control Panel:
 * The view: RequestWaterView.xib
 * The viewController: self
 */
@property (strong, nonatomic) UIView *requestWaterView;
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

/*
 * "RatingsAndFeedback" Control Panel:
 * The view: RatingsAndFeedbackView.xib
 * The viewController: RatingsAndFeedbackViewContoller
 *  (the view contains table, so its controller is not self, in order to seperate concerns)
 */

@property (strong, nonatomic) RatingAndFeedbackViewController * ratingAndFeedbackViewController;
@property (strong, nonatomic) UIView *ratingsAndFeedbackView;

// For container view:
@property (weak,nonatomic) UIViewController *destinationViewController;
@property (strong, nonatomic) NSString *destinationIdentifier;
@property (strong, nonatomic) UIViewController *oldViewController;

// For the item quantity label:
@property (strong, nonatomic) IBOutlet UILabel *itemQuantityLabel;
@property (strong, nonatomic) IBOutlet UIImageView *itemQuantityLabelBackgroundImageView;

//For the case when user wants to place an order from order history
@property BOOL arrivedFromOrderHistory;

@end
