//
//  PastOrderDetailViewController.h
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 19/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PastOrderDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property NSString *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *restuarantNameLabel;
@property NSString *orderTime;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property NSArray *meals;
@property (weak, nonatomic) IBOutlet UITableView *mealsTableView;
@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceChargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gstLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end
