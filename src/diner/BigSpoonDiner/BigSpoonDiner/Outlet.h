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
@property (nonatomic, strong) NSDate *timeOpen;
@property (nonatomic, strong) NSDate *timeClose;

@end
