//
//  Outlet.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Outlet.h"

@implementation Outlet

@synthesize imgURL;

@synthesize name;

@synthesize address;    
@synthesize phoneNumber;
@synthesize operatingHours;

- (id) initWithImgURL:(NSURL *)u Name:(NSString *)n Address:(NSString *)a PhoneNumber:(NSString *)p OperationgHours:(NSString *)o{
    self = [super init];
    if (self) {
        self.imgURL = u;
        self.name = n;
        self.address = a;
        self.phoneNumber = p;
        self.operatingHours = o;
    }
    return self;
}

@end
