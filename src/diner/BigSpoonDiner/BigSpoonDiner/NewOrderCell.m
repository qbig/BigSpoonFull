//
//  newOrderCell.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 30/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "NewOrderCell.h"
#import "Constants.h"

@implementation NewOrderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) hideNote{
    self.orderNote.hidden = YES;
}

- (void) displayNote {
    self.orderNote.hidden = NO;
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
