//
//  pastOrderCell.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 30/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PastOrderCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifierDetailsLabel;

@property (nonatomic) float requiredCellHeight;
@end
