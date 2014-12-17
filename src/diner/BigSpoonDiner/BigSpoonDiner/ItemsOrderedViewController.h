//
//  itemsOrderedTableViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 29/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

#import "NewOrderCell.h"
#import "PastOrderCell.h"
#import "Dish.h"
#import "Constants.h"
#import "BigSpoonAnimationController.h"
#import "UIViewController+KeyboardEvents.h"
#import "TestFlight.h"
#import "User.h"
#import "DishModifierSegueDelegate.h"
#import <Mixpanel.h>
#import "DishModifierTableViewController.h"

@class ItemsOrderedViewController;

@protocol PlaceOrderDelegate <NSObject>

- (Order *) addDishWithIndex: (int) dishIndex;
- (Order *) minusDishWithIndex: (int) dishIndex;
- (Order *) addDish: (Dish*) dish;
- (Order *) addNote: (NSString*)note toDishAtIndex: (int) dishIndex;
- (void) placeOrderWithNotes: (NSString*)notes;
- (Order *) getCurrentOrder;
- (Order *) getPastOrder;

@end

@interface ItemsOrderedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DishModifierSegueDelegate>

@property (nonatomic, weak) id <PlaceOrderDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)plusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)minusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)placeOrderButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *addNotesButton;
@property (strong, nonatomic) IBOutlet UITableView *currentOrderTableView;
@property (strong, nonatomic) IBOutlet UITableView *pastOrderTableView;
@property (strong, nonatomic) IBOutlet __block UIButton *placeOrderButton;
@property (strong, nonatomic) User * userInfo;


- (void) setGSTRate: (double) gstRate andServiceChargeRate: (double) serviceChargeRate;
- (void) reloadOrderTablesWithCurrentOrder:(Order*) currentOrder andPastOrder:(Order*) pastOrder;
- (IBAction) textFinishEditing:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *addNotesTextField;
@property (weak, nonatomic) IBOutlet UIImageView *sentOrderBackgrountImageView;

// Price tags:

@property (strong, nonatomic) IBOutlet UILabel *currentSubtotalLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentServiceChargeLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentGSTLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentTotalLabel;

@property (strong, nonatomic) IBOutlet UILabel *pastSubtotalLabel;
@property (strong, nonatomic) IBOutlet UILabel *pastServiceChargeLabel;
@property (strong, nonatomic) IBOutlet UILabel *pastGSTLabel;
@property (strong, nonatomic) IBOutlet UILabel *pastTotalLabel;

@property (strong, nonatomic) IBOutlet UILabel *currentServiceChargeTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *currentGSTTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *pastServiceChargeTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *pastGSTTitleLabel;

@property (strong, nonatomic) IBOutlet UIView *viewContainerForAfterCurrentOrderTable;

@property (strong, nonatomic) IBOutlet UIView *viewContainerForAfterPastOrderTable;


@end
