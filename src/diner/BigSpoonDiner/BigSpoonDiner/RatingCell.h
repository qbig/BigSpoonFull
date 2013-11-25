//
//  RatingCell.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 14/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dishNameLabel;

@property (strong, nonatomic) IBOutlet UIImageView *ratingImage;

@end
