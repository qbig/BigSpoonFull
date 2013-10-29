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

@class ItemsOrderedViewController;

@protocol PlaceOrderDelegate <NSObject>
- (void)orderQuantityHasChanged: (Order *)order;
@end

@interface ItemsOrderedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <PlaceOrderDelegate> delegate;
@property (nonatomic, strong) Order *currentOrder;
@property (nonatomic, strong) Order *pastOrder;

- (IBAction)plusButtonPressed:(UIButton *)sender;
- (IBAction)minusButtonPressed:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UITableView *currentOrderTableView;
@property (strong, nonatomic) IBOutlet UITableView *pastOrderTableView;

@end
