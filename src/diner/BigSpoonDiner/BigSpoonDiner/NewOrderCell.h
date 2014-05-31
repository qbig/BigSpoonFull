//
//  newOrderCell.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 30/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface NewOrderCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifierDetailsLabel;

@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIButton *minusButton;

@property (strong, nonatomic) IBOutlet UITextField *orderNote;

@property (nonatomic) float requiredCellHeight;
- (void) hideNote;
- (void) displayNote;

@end
