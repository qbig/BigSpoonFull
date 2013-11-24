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
    if (self)
    {
        // Initialization code.
        //
        [[NSBundle mainBundle] loadNibNamed:@"PastOrderView" owner:self options:nil];
        [self addSubview:self.contentView];
    }
    return self;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"PastOrderView" owner:self options:nil];
        [self addSubview:self.contentView];
    }
    NSLog(@"I am in custom init");
    return self;
}

-(void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"PastOrderView" owner:self options:nil];
    [self addSubview: self.contentView];
}

- (id) initAtIndex: (int)pastOrderCount {
    [[NSBundle mainBundle] loadNibNamed:@"PastOrderView" owner:self options:nil];
    CGRect newFrame = self.frame;
    newFrame.size.width = self.contentView.frame.size.width;
    newFrame.origin.y = self.contentView.frame.size.height * pastOrderCount;
    newFrame.size.height = self.contentView.frame.size.height;
    self = [super initWithFrame:newFrame];
    [self addSubview:self.contentView];
    return self;
}

- (IBAction)openOrderDetail:(id)sender {
//    UIViewController * viewController = [self firstAvailableUIViewController];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    PastOrderDetailViewController *pastOrderDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"Order History"];
//    pastOrderDetailViewController.restaurantName = self.restaurantNameLabel.text;
//    pastOrderDetailViewController.orderTime = self.orderTime.text;
//    pastOrderDetailViewController.meals = [NSArray arrayWithArray:self.meals];
//    [viewController.navigationController pushViewController:pastOrderDetailViewController animated:YES];
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
