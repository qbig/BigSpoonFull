//
//  DishModifierTableViewController.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DishModifier.h"
#import "DishModifierSection.h"
#import "DishModifierItem.h"
#import "DishModifierSegueDelegate.h"
#import "Dish.h"

@interface DishModifierTableViewController : UITableViewController
@property (nonatomic, strong) Dish* targetingDish;
@property (nonatomic, strong) id <DishModifierSegueDelegate> delegate;
@end
