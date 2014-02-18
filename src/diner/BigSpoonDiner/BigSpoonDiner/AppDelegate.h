//
//  AppDelegate.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 12/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>
#import <Mixpanel.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "Constants.h"
#import "User.h"
#import "TestFlight.h"
#import "SSKeychain.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SocketIODelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SocketIO *socketIO;
@property (nonatomic) BOOL isSocketConnected;

@property (strong, nonatomic) Mixpanel *mixpanel;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) NSDate *bgUsageStart;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSTimer* timer;

- (void) connectSocket;
- (void) disconnectSocket;

@end
