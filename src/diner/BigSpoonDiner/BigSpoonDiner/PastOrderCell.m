//
//  pastOrderCell.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 30/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "PastOrderCell.h"

@implementation PastOrderCell

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


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize maxSize = CGSizeMake(167.0f, CGFLOAT_MAX);
    CGSize requiredSize = [self.modifierDetailsLabel sizeThatFits:maxSize];
    self.modifierDetailsLabel.frame = CGRectMake(self.modifierDetailsLabel.frame.origin.x, self.modifierDetailsLabel.frame.origin.y, requiredSize.width, requiredSize.height);
    
    self.requiredCellHeight = 15.0f + 3.0f + 7.0f + 30.0f;
    self.requiredCellHeight += self.modifierDetailsLabel.frame.size.height;
}

@end
