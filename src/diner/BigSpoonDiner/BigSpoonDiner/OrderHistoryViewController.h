//
//  OrderHistoryViewController
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 14/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeAndSettingsButtonView.h"
#import "Constants.h"
#import "User.h"
#import "PastOrderView.h"
#import <MessageUI/MessageUI.h> 
#import <Mixpanel.h>

@class OrderHistoryViewController;

@interface OrderHistoryViewController : UIViewController <NSURLConnectionDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *orderHistoryScrollView;
@property (weak, nonatomic) IBOutlet UILabel *suggestionLabel;

@end
