//
//  Dish.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Dish.h"

@implementation Dish
@synthesize description;

- (id) initWithName: (NSString *) n
        Description: (NSString *) d
              Price: (double) p
            Ratings: (int) r
                 ID: (int) I
         categories: (NSArray *) c
             imgURL: (NSURL *) img
                pos: (int) po
              index: (int) index
          startTime: (NSString *)sta
            endTime: (NSString *)end
           quantity: (int) qu
    canBeCustomized: (BOOL) canBe
    customOrderInfo: (DishModifier*) cusInfo{
    
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
        self.index = index;
        self.startTime = sta;
        self.endTime = end;
        self.quantity = qu;
        self.canBeCustomized = canBe;
        self.customOrderInfo = cusInfo;
    }
    return self;
}

@end
