//
//  Outlet.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Outlet : NSObject

@property (nonatomic, strong) NSURL *imgURL;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *operatingHours;
@property (nonatomic) int outletID;
@property (nonatomic, strong) NSString *promotionalText;
@property (nonatomic) double gstRate;
@property (nonatomic) double serviceChargeRate;

- (id) initWithImgURL: (NSURL *) u Name: (NSString *) n Address: (NSString *) a PhoneNumber: (NSString *) phone OperationgHours: (NSString *) o OutletID: (int) i  promotionalText: (NSString *) pro  gstRate: (double) g serviceChargeRate: (double) s;

@end
