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
#import "UILabel+Alignment.h"
#import "TestFlight.h"
#import "DishModifier.h"
#import "DishModifierSegueDelegate.h"
#import "DishModifierTableViewController.h"

enum DishDisplayMethod : NSUInteger {
    kMethodList = 1,
    kMethodPhoto = 2,
};

@class MenuTableViewController;

@protocol OrderDishDelegate <NSObject>
- (void)dishOrdered: (Dish *)dish;
- (void)setValidTableIDs: (NSDictionary *)validTableIDs;
- (void)updateCounter;
@end

@protocol MenuDisplayModeDelegate <NSObject>
- (void)displayModeDidChange;
@end

@interface MenuTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DishModifierSegueDelegate>

@property (nonatomic, strong) NSMutableArray *dishesArray;
@property (nonatomic, strong) NSMutableArray *dishCategoryArray;
@property (nonatomic) int displayCategoryID;
@property (nonatomic) int displayCategoryPosition;


@property (nonatomic, strong) id <OrderDishDelegate, MenuDisplayModeDelegate> delegate;

@property (nonatomic, strong) Outlet *outlet;
@property (nonatomic, strong) NSDictionary* jsonForDishesTablesAndCategories;
@property (nonatomic) enum DishDisplayMethod displayMethod;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *categoryButtonsHolderView;
@property (strong, nonatomic) NSMutableArray *categoryButtonsArray;

- (IBAction)addNewItemButtonClicked:(id)sender;

- (Dish *) getDishWithID: (int) itemID;



@end
