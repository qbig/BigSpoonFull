//
//  User.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <AFHTTPRequestOperationManager.h>
#import "Constants.h"
#import "Outlet.h"
#import "Order.h"
#import <Mixpanel.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic) int tableID;

@property (nonatomic, strong) Outlet *currentOutlet;
@property (nonatomic) NSDictionary *validTableIDs;
@property (nonatomic, strong) Order *currentOrder;
@property (nonatomic, strong) Order *pastOrder;
@property (nonatomic, strong) CLLocation* userLocation;
@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic, strong) NSUserDefaults *userDefault;
@property (nonatomic) BOOL locationAvailableForChecking;

+ (User *)sharedInstance;
- (void) attemptToLoginToFB;
- (void) loadDishesAndTableInfosFromServerForOutlet: (int) outletID;
- (void) saveInfoString:(NSString *)info ForKey: (NSString*) key;
- (NSString *) getInfoStringForKey: (NSString *) key;
- (void) saveObject:(id) obj forKey: (NSString*) key;
- (id) getObjectForKey: (NSString*) key;
- (void) setOutletData: (id) obj forOutletID:(int) outletID;
- (id) getOutletDataWithID: (int) outletID;
@end
