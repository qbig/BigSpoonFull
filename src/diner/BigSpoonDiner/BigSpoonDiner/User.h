//
//  User.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

@property (nonatomic, strong) NSString *emal;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSString *accessToken;

+ (User *)sharedInstance;

@end
