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

@class ItemsOrderedViewController;

@protocol PlaceOrderDelegate <NSObject>

- (Order *) addDishWithID: (int) dishID;
- (Order *) minusDishWithID: (int) dishID;
- (void) placeOrderWithNotes: (NSString*)notes;
- (Order *) getCurrentOrder;
- (Order *) getPastOrder;

@end

@interface ItemsOrderedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) id <PlaceOrderDelegate> delegate;
@property (nonatomic, strong) Order *currentOrder;
@property (nonatomic, strong) Order *pastOrder;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)plusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)minusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event;

@property (strong, nonatomic) IBOutlet UITableView *currentOrderTableView;
@property (strong, nonatomic) IBOutlet UITableView *pastOrderTableView;

- (IBAction)placeOrderButtonPressed:(id)sender;

- (void) setGSTRate: (double) gstRate andServiceChargeRate: (double) serviceChargeRate;
- (void) reloadOrderTablesWithCurrentOrder:(Order*) currentOrder andPastOrder:(Order*) pastOrder;
- (IBAction) textFinishEditing:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *addNotesTextField;

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
