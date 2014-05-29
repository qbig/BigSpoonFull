//
//  DishModifierItemCellCount.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 29/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DishModifierItemCellCount.h"

@implementation DishModifierItemCellCount

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)minusButtonPressed:(id)sender {
    if( self.item.itemCount >= 1) {
        self.item.itemCount--;
        self.itemCountLabel.text = [NSString stringWithFormat:@"%d", self.item.itemCount];
    }
}

- (IBAction)plusButtonPressed:(id)sender {
    self.item.itemCount++;
    self.itemCountLabel.text = [NSString stringWithFormat:@"%d", self.item.itemCount];
}
@end
