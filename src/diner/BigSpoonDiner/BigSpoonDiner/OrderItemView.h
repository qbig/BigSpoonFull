//
//  OrderItemView.h
//  BigSpoonDiner
//
//  Created by Leon Qiao on 28/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderItemView : UIView
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dishNameLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

- (id) initAtIndex: (int)pastOrderCount;
@end
