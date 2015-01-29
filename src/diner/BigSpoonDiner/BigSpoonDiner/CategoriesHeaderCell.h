//
//  CategoriesHeaderCell.h
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/1/15.
//  Copyright (c) 2015 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface CategoriesHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *restaurantIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *openHoursLabel;

@end
