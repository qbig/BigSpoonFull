//
//  Dish.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Dish.h"

@implementation Dish

@synthesize name;
@synthesize description;
@synthesize price;
@synthesize ratings;

- (id) initWithName: (NSString *) n Description: (NSString *) d Price: (int) p Ratings: (int) r{
    self = [super init];
    if (self) {
        self.name = n;
        self.description = d;
        self.price = p;
        self.ratings = r;
    }
    return self;
}

@end
