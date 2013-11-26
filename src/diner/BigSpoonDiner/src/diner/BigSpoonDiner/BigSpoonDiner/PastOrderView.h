//
//  PastOrderView.h
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKitCategories.h"
#import "PastOrderDetailViewController.h"

@interface PastOrderView : UIView
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property NSArray *meals;

- (id) initAtIndex: (int)pastOrderCount;
- (IBAction)openOrderDetail:(id)sender;

@end
