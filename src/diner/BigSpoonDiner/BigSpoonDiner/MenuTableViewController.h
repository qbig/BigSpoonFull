//
//  MenuTableViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"
#import "MenuListCell.h"
#import "MenuPhotoCell.h"
#import "Constants.h"
#import "Outlet.h"
#import "BigSpoonAnimationController.h"
#import "DishCategory.h"
#import <AFHTTPRequestOperationManager.h>
#import "User.h"

enum DishDisplayMethod : NSUInteger {
    kMethodList = 1,
    kMethodPhoto = 2,
};

@class MenuTableViewController;

@protocol OrderDishDelegate <NSObject>
- (void)dishOrdered: (Dish *)dish;
- (void)validTableRetrieved: (NSArray *)validTableIDs;
@end

@interface MenuTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dishesArray;
@property (nonatomic, strong) NSMutableArray *dishCategoryArray;

@property (nonatomic, strong) id <OrderDishDelegate> delegate;

@property (nonatomic, strong) Outlet *outlet;

@property (nonatomic) enum DishDisplayMethod displayMethod;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addNewItemButtonClicked:(id)sender;

- (Dish *) getDishWithID: (int) itemID;



@end
