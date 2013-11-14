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

enum DishDisplayMethod : NSUInteger {
    kMethodList = 1,
    kMethodPhoto = 2,
};

enum DishDisplayCategory : NSUInteger{
    kCategoryBreakfast = 1,
    kCategoryMains = 2,
    kCategorySides = 3,
    kCategoryBeverages = 4
};

@class MenuTableViewController;

@protocol OrderDishDelegate <NSObject>
- (void)dishOrdered: (Dish *)dish;
- (void)validTableRetrieved: (NSArray *)validTableIDs;
@end

@interface MenuTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dishesArray;

@property (nonatomic, strong) id <OrderDishDelegate> delegate;

@property (nonatomic, strong) Outlet *outlet;

@property (nonatomic) enum DishDisplayMethod displayMethod;
@property (nonatomic) enum DishDisplayCategory displayCategory;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)breakfastButtonPressed:(id)sender;

- (IBAction)mainsButtonPressed:(id)sender;

- (IBAction)beveragesButtonPressed:(id)sender;

- (IBAction)sidesAndSnacksButtonPressed:(id)sender;

- (IBAction)addNewItemButtonClicked:(id)sender;

- (Dish *) getDishWithID: (int) itemID;



@end
