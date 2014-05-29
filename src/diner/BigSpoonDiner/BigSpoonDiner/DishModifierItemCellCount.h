//
//  DishModifierItemCellCount.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 29/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DishModifierItem.h"
@interface DishModifierItemCellCount : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (weak, nonatomic) DishModifierItem *item;
- (IBAction)minusButtonPressed:(id)sender;
- (IBAction)plusButtonPressed:(id)sender;

@end
