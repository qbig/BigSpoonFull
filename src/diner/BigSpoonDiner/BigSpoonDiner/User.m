//
//  User.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize password;
@synthesize birthday;
@synthesize auth_token;

+ (User *)sharedInstance
{
    static User *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[User alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

@end
