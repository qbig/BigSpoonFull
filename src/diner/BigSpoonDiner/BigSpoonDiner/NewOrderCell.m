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

@end
