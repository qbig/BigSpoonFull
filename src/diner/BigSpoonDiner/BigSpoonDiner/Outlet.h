//
//  Outlet.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+Eclipsize.h"
@interface Outlet : NSObject

@property (nonatomic, strong) NSURL *imgURL;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *operatingHours;
@property (nonatomic, strong) NSString *defaultDishPhoto;
@property (nonatomic) int outletID;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (nonatomic, strong) NSString *promotionalText;
@property (nonatomic) double gstRate;
@property (nonatomic) double serviceChargeRate;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isDefaultPhotoMenu;
@property (nonatomic) BOOL isWaterEnabled;
@property (nonatomic, strong) NSString *waterText;
@property (nonatomic) BOOL  isBillEnabled;
@property (nonatomic, strong) NSString *billText;
@property (nonatomic) double locationThreshold;

- (id) initWithImgURL: (NSURL *) u
                 Name: (NSString *) n
              Address: (NSString *) a
          PhoneNumber: (NSString *) phone
      OperationgHours: (NSString *) o
     defaultDishPhoto:(NSString *)pho
             OutletID: (int) i
                  lat:(double)lat
                  lon:(double)lon
      promotionalText: (NSString *) pro
              gstRate: (double) g
    serviceChargeRate: (double) s
             isActive: (BOOL) is
          isPhotoMenu:(BOOL)isP
isRequestForWaterEnabled: (BOOL)isWaterEnabled
            waterText: (NSString*) wt
isRequestForBillEnabled: (BOOL)isBillEnabled
             billText: (NSString*)bt
    locationThreshold: (double) lt;

- (double) distanceFrom: (CLLocation*) userLocation;

@end
