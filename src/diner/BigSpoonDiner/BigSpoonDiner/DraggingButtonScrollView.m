//
//  DraggingButtonScrollView.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 6/10/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DraggingButtonScrollView.h"

@implementation DraggingButtonScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return YES;
}

@end
