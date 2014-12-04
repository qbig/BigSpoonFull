//
//  OutletCell.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface OutletCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *outletPhoto;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *address;
@property (nonatomic, strong) IBOutlet UILabel *phoneNumber;
@property (nonatomic, strong) IBOutlet UILabel *operatingHours;
@property (strong, nonatomic) IBOutlet UILabel *promotionTextLabel;

@end
