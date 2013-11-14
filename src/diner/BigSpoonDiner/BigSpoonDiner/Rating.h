//
//  Rating.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 14/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rating : NSObject

// Key: dishID. Value: rating from [0---5]
@property (nonatomic, strong) NSDictionary *ratings;

// Set the rating of dishID to newRating
- (void) setRatingsOfDish: (int) dishID toRating: (int) newRating;

@end
