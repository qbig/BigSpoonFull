//
//  OrderItemView.m
//  BigSpoonDiner
//
//  Created by Leon Qiao on 28/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "OrderItemView.h"
#import "Constants.h"
@implementation OrderItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"OrderItemView" owner:self options:nil];
        [self addSubview:self.containerView];
    }
    return self;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"PastOrderView" owner:self options:nil];
        [self addSubview:self.containerView];
    }
    return self;
}


-(void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"OrderItemView" owner:self options:nil];
    [self addSubview: self.containerView];
}

- (id) initAtIndex: (int)index {
    // index desiding the position
    [[NSBundle mainBundle] loadNibNamed:@"OrderItemView" owner:self options:nil];
    CGRect newFrame = self.frame;
    newFrame.size.width = self.containerView.frame.size.width;
    newFrame.origin.y = self.containerView.frame.size.height * index + ORDER_CONFIRM_ALERT_TITLE_HEIGHT;
    newFrame.size.height = self.containerView.frame.size.height;
    self = [super initWithFrame:newFrame];
    [self addSubview: self.containerView];
    return self;
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
