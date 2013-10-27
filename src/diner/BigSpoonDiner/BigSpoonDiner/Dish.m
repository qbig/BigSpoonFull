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


@synthesize ID;
@synthesize categories;
@synthesize imgURL;
@synthesize pos;
@synthesize startTime;
@synthesize endTime;
@synthesize quantity;

- (id) initWithName: (NSString *) n
        Description: (NSString *) d
              Price: (int) p
            Ratings: (int) r
                 ID: (int) I
         categories: (NSArray *) c
             imgURL: (NSURL *) img
                pos: (int) po
          startTime: (NSString *)sta
            endTime: (NSString *)end
           quantity: (int) qu{
    
    self = [super init];
    if (self) {
        self.name = n;
        self.description = d;
        self.price = p;
        self.ratings = r;
        
        self.ID = I;
        self.categories = c;
        self.imgURL = img;
        self.pos = po;
        self.startTime = sta;
        self.endTime = end;
        self.quantity = qu;
    }
    return self;
}

@end
