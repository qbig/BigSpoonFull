//
//  OutletsViewController.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Outlet.h"
#import "URLImageView.h"
#import "OutletCell.h"
#import "MenuViewController.h"
#import "User.h"

@interface OutletsTableViewController : UITableViewController <MenuViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *outletsArray;

@end
