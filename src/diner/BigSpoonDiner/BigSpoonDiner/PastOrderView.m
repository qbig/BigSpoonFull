//
//  PastOrderView.m
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "PastOrderView.h"

@implementation PastOrderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"PastOrderView" owner:self options:nil];
    [self addSubview: self.contentView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
