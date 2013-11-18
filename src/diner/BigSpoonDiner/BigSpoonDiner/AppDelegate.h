//
//  AppDelegate.h
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 12/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "Constants.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SocketIODelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SocketIO *socketIO;
@property (nonatomic) BOOL isSocketConnected;

- (void) connectSocket;
- (void) disconnectSocket;

@end
