//
//  CategoryTableViewController.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/1/15.
//  Copyright (c) 2015 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExitMenuListDelegate.h"
#import "Outlet.h"
#import "User.h"

@interface CategoriesTableViewController : UITableViewController
@property (nonatomic, weak) id <ExitMenuListDelegate> delegate;
@property (nonatomic, strong) Outlet *outlet;
@property (nonatomic, strong) NSDictionary *jsonForDishesTablesAndCategories;
@property (nonatomic, strong) User *userInfo;
@end
