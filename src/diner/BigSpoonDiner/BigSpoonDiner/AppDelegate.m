//
//  AppDelegate.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 12/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate{
    // Load outlets when we load the app
    NSMutableArray *outletsArray;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    self.isSocketConnected = NO;
    
    [TestFlight takeOff:@"069657b9-d915-4404-bad9-9aa6bb1968dc"];
    
    return YES;
}

- (void)loadOutlets{
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self disconnectSocket];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self connectSocket];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self disconnectSocket];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark - Socket Connection

// Delegate method which will be called by menuViewController

- (void) connectSocket{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSString *email = [prefs stringForKey:@"email"];
    NSString *auth_token = [SSKeychain passwordForService:@"BigSpoon" account:email];
    
    if (auth_token == nil) {
        NSLog(@"In AppDelegate, connectSocket detects that the user is not registered");
        return;
    }
    
    if (!self.isSocketConnected) {
        
        // If the socket fails to connect. This field will be set to NO in delegate method:
        // - (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
        
        self.isSocketConnected = YES;

        self.socketIO = [[SocketIO alloc] initWithDelegate:self];
        [self.socketIO connectToHost:SOCKET_URL onPort:SOCKET_PORT];
    } else{
        NSLog(@"In AppDelegate, connectSocket detects that the socket is connected");
    }
}

- (void) disconnectSocket{
    [self.socketIO disconnect];
    self.isSocketConnected = NO;
    self.socketIO = nil;
}

#pragma mark - socketIO Deletage

- (void) socketIODidConnect:(SocketIO *)socket{
    NSLog(@"In App Delegate: socketIODidConnect");
    
    User *user = [User sharedInstance];
    
    [self.socketIO sendMessage:[NSString stringWithFormat:@"subscribe:u_%@", user.authToken]];
    self.isSocketConnected = YES;
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error{
    NSLog(@"In App Delegate: socketIODidDisconnect disconnectedWithError");
    self.isSocketConnected = NO;
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet{
    NSLog(@"In App Delegate: didReceiveMessage");
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet{
    NSLog(@"In App Delegate: didReceiveJSON");
    
    NSDictionary *response = (NSDictionary *)[packet dataAsJSON];
    response = (NSDictionary *)[response objectForKey:@"message"];
    
    NSString *type = [response objectForKey:@"type"];
    if ([type isEqualToString:@"message"]) {
        
        NSString *messages = [response objectForKey:@"data"];
        int startIndexForDishName = [messages rangeOfString:@"[" options:NSBackwardsSearch].location;
        int endIndexForDishName = [messages rangeOfString:@"]" options:NSBackwardsSearch].location;
        if (startIndexForDishName != NSNotFound){
            NSString *nameForUpdatedDish = [messages substringWithRange:NSMakeRange(startIndexForDishName  + 1, endIndexForDishName - startIndexForDishName - 1)];
            [[User sharedInstance].pastOrder decrementDishName:nameForUpdatedDish];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ORDER_UPDATE object:nil];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:messages
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
    
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet{
    NSLog(@"In App Delegate: didReceiveEvent");
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet{
    NSLog(@"In App Delegate: didSendMessage %@", packet.data);
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error{
    NSLog(@"In App Delegate: socketIO onError");
    self.isSocketConnected = NO;
}

@end
