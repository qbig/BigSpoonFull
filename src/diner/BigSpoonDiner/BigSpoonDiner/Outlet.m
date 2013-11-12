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
@synthesize outletID;

- (id) initWithImgURL:(NSURL *)u
                 Name:(NSString *)n
              Address:(NSString *)a
          PhoneNumber:(NSString *)p
      OperationgHours:(NSString *)o
             OutletID:(int)i
      promotionalText: (NSString *) pro
              gstRate: (double) g
    serviceChargeRate: (double) s{
    
    self = [super init];
    if (self) {
        self.imgURL = u;
        self.name = n;
        self.address = a;
        self.phoneNumber = p;
        self.operatingHours = o;
        self.outletID = i;
        self.promotionalText = pro;
        self.gstRate = g;
        self.serviceChargeRate = s;
    }
    return self;
}

@end
