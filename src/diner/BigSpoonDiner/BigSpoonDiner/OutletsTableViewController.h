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
#import "User.h"
#import "Constants.h"
#import "Order.h"
#import "ExitMenuListDelegate.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ImageCache.h"
#import "SSKeychain.h"
#import "EAIntroView.h"

@interface OutletsTableViewController : UITableViewController <ExitMenuListDelegate, NSURLConnectionDelegate, EAIntroDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *outletsArray;

// Need to record the order items,
// If the user ordered some items and comes out to the main page.
// When the user goes to that outlet again, we should restore his/her previous selection
@property (nonatomic) int outletIDOfPreviousSelection;
@property (nonatomic) int tableIDOfPreviousSelection;
@property (nonatomic, strong) Order * currentOrder;
@property (nonatomic, strong) Order * pastOrder;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) EAIntroView *intro;
- (IBAction)logoutButtonPressed:(id)sender;


@end
