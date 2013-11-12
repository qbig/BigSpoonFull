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
@property (nonatomic) double lat;
@property (nonatomic) double lon;

- (id) initWithImgURL: (NSURL *) u Name: (NSString *) n Address: (NSString *) a PhoneNumber: (NSString *) p OperationgHours: (NSString *) o OutletID: (int) i lat:(double)lat lon:(double)lon;

@end
