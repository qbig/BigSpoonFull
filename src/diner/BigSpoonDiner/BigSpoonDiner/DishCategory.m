//
//  DishCatetory.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 16/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DishCategory.h"


@implementation DishCategory
@synthesize description = _description;

- (id) initWithID: (int) i name: (NSString*) n andDescription: (NSString*) d isListOnly: (BOOL)is {
    self = [super init];
    if (self) {
        self.ID = i;
        self.name = n;
        self.description = d;
        self.isListOnly = is;
    }
    return self;
}

@end
