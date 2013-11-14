//
//  BigSpoonAnimationController.h
//
// BigSpoonAnimationController is a public class that provides commonly-used animation functions across the app
// It never maintains a state
//
//  Created by Zhixing Yang on 14/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface BigSpoonAnimationController : NSObject

+ (void) animateTransitionOfUIView: (UIView *)view willShow: (BOOL) willShow;

+ (void) animateBadgeAfterUpdate: (UIView *)badgeView withOriginalFrame: (CGRect) oldFrameItemBadge;

@end
