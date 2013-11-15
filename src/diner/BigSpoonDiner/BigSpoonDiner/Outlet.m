//
//  Outlet.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Outlet.h"

@implementation Outlet

- (id) initWithImgURL:(NSURL *)u
                 Name:(NSString *)n
              Address:(NSString *)a
          PhoneNumber:(NSString *)p
      OperationgHours:(NSString *)o
             OutletID:(int)i
                  lat:(double)latitude
                  lon:(double)longitude
      promotionalText: (NSString *) pro
              gstRate: (double) g
    serviceChargeRate: (double) s {
    self = [super init];
    if (self) {
        self.imgURL = u;
        self.name = n;
        self.address = a;
        self.phoneNumber = p;
        self.operatingHours = o;
        self.outletID = i;
        self.lat = latitude;
        self.lon = longitude;
        self.promotionalText = pro;
        self.gstRate = g;
        self.serviceChargeRate = s;
    }
    return self;
}

@end
