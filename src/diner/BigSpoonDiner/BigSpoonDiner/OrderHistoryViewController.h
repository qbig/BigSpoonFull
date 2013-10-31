//
//  SettingsViewController.h
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 14/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeAndSettingsButtonView.h"
//#import "PastOrderView.h"

@interface OrderHistoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *orderHistoryScrollView;
@property (weak, nonatomic) HomeAndSettingsButtonView *topRightButtonsView;

@end
