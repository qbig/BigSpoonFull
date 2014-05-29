//
//  DishModifierItemCellRadio.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 29/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DishModifierItemCellRadio.h"

@implementation DishModifierItemCellRadio

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellState = Unchecked;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)awakeFromNib
{
    self.cellState = Unchecked;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:NO];
}

- (void) check{
    self.selectedIndicatorImageview.hidden = NO;
    self.item.itemCount = 1;
    self.cellState = Checked;
    self.selectedIndicatorImageview.image = [self.selectedIndicatorImageview.image imageWithColor:self.selectorColor];
}

- (void) uncheck{
    self.selectedIndicatorImageview.hidden = YES;
    self.item.itemCount = 0;
    self.cellState = Unchecked;
}

- (radioCellState) toggle {
    if (self.cellState == Unchecked){
        [self check];
    } else {
        [self uncheck];
    }
    return self.cellState;
}

- (void) tapTransition
{
    self.tapTransitionsOverlay.alpha = 0.0;
    [UIView beginAnimations:@"tapTransition" context:nil];
    [UIView setAnimationDuration:0.8];
    self.tapTransitionsOverlay.alpha = 1.0;
    [UIView commitAnimations];
}

@end
