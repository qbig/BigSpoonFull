//
//  User.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Outlet.h"
#import "Order.h"

@interface User : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *authToken;

@property (nonatomic, strong) Outlet *currentOutlet;
@property (nonatomic) NSDictionary *validTableIDs;
@property (nonatomic, strong) Order *currentOrder;
@property (nonatomic, strong) Order *pastOrder;

+ (User *)sharedInstance;
- (void) attemptToLoginToFB;

@end
