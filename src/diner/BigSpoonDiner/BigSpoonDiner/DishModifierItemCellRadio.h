//
//  DishModifierItemCellRadio.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 29/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DishModifierItemCellRadio : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedIndicatorImageview;

- (IBAction)radioButtonPressed:(id)sender;

@end
