//
//  UILabel+Alignment.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 19/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UILabel (extendAlignmentMetnods)

// iOS doesn't provie these funtions to align texts in UILabel. Hence we need to extend it:
- (void) alignTop;
- (void) alignBottom;

@end
