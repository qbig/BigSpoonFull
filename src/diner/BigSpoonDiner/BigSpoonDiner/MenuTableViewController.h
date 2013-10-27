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

@interface MenuTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *dishesArray;
- (IBAction)breakfastButtonPressed:(id)sender;

- (IBAction)mainsButtonPressed:(id)sender;

- (IBAction)beveragesButtonPressed:(id)sender;


- (IBAction)sidesAndSnacksButtonPressed:(id)sender;


@end
