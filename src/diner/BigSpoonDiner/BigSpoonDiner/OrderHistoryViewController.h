//
//  OrderHistoryViewController
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 14/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeAndSettingsButtonView.h"
//#import "PastOrderView.h"

@class OrderHistoryViewController;

@protocol SettingsViewControllerDelegate <NSObject>
- (void)cancelButtonPressed: (OrderHistoryViewController *)controller;
@end


@interface OrderHistoryViewController : UIViewController

@property (nonatomic, weak) id <SettingsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *orderHistoryScrollView;
@property (weak, nonatomic) HomeAndSettingsButtonView *topRightButtonsView;

@end
