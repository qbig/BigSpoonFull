//
//  RatingCell.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 14/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RatingCell.h"

@implementation RatingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
