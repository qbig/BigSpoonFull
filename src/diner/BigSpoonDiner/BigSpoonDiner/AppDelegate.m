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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email = [prefs stringForKey:@"email"];
    NSString *auth_token = [SSKeychain passwordForService:@"BigSpoon" account:email];
    [User sharedInstance].authToken = auth_token;

    [TestFlight takeOff:@"069657b9-d915-4404-bad9-9aa6bb1968dc"];
    
    self.mixpanel = [Mixpanel sharedInstanceWithToken:@"cd299a9c637a72d3d95d6cec378ad91e"];
    [self.mixpanel identify:self.mixpanel.distinctId];
    self.mixpanel.checkForSurveysOnActive = YES;
    self.mixpanel.showSurveyOnActive = YES;
    self.mixpanel.flushInterval = 60;
    [self initLocationManager];
    [[NSNotificationCenter defaultCenter] addObserver:self.locationManager selector:@selector(startUpdatingLocation) name:NOTIF_SHOULD_ASK_LOCATION_PERMIT_NOT object:nil];
    return YES;
}

- (void)initLocationManager{
    //initialize geolocation
    if(self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
}

- (void)startTrackingLocation{
    if([[User sharedInstance].userDefault boolForKey:KEY_FOR_SHOW_TUT_DEFAULT]){
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
        if (newLocation.horizontalAccuracy < 0) {
            return;
        }
        [User sharedInstance].userLocation = newLocation;
 
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self disconnectSocket];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if([[User sharedInstance].userDefault boolForKey:KEY_FOR_SHOW_TUT_DEFAULT]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self beginBackgroundUpdateTask];
            
            [self initLocationManager];
            [self.locationManager stopMonitoringSignificantLocationChanges];
            [self startTrackingLocation];
            [self endBackgroundUpdateTask];
        });
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self connectSocket];
    @try {
        [self updateOrder];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    self.bgUsageStart = [NSDate date];
    [self.mixpanel track:@"Usage Starts" properties:@{@"time": self.bgUsageStart}];
    [self.mixpanel.people increment:@"Number of App Launch" by: [NSNumber numberWithInt:1]];
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

    if ([User sharedInstance].authToken == nil) {
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
    [self connectSocket];
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
        int startTockenForDishName = [messages rangeOfString:@"[" options:NSBackwardsSearch].location;
        //int endTockenForDishName = [messages rangeOfString:@"]" options:NSBackwardsSearch].location;
        if (startTockenForDishName != NSNotFound){
            @try {
                [self updateOrder];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ORDER_UPDATE object:nil];
        } else if ([messages rangeOfString:SOCKET_IO_TOKEN_BILL_CLOSED].location != NSNotFound){
            // clean user session
            [self closeCurrentSession];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:messages
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
    
}

- (void) closeCurrentSession{
    [User sharedInstance].tableID = -1;
    [User sharedInstance].pastOrder = [[Order alloc] init];
    [User sharedInstance].currentOrder = [[Order alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ORDER_UPDATE object:nil];
}

- (void) updateOrder{
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: ORDER_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        int responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{
                NSLog(@"Update Order request success");
                NSDictionary* json = (NSDictionary*)responseObject;
                BOOL changed = [self updateOrderWithJsonIfNecessary: json];
                
                if (changed){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ORDER_UPDATE object:nil];
                }
            }
                break;
            case 404:
                [self closeCurrentSession];
                break;
            case 403:
            default:{
                NSLog(@"Update Order Fail");
            }
        }
        NSLog(@"JSON: %@", responseObject);
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"%@", error);
                                      }];
    [operation start];
}

- (BOOL) updateOrderWithJsonIfNecessary:(NSDictionary *)json {
    BOOL changed = FALSE;
    NSDictionary *ordersDict = [json objectForKey:@"orders"];
    User *user = [User sharedInstance];
    Order *updatedOrder = [[Order alloc] init];
    for(NSDictionary * dict in ordersDict){
        NSDictionary* dishDic = [dict objectForKey:@"dish"];
        Dish *tmpDish = [[Dish alloc] init];
        tmpDish.name = [dishDic objectForKey:@"name"];
        tmpDish.ID = [[dishDic objectForKey:@"id"] integerValue];
        tmpDish.price = [[dishDic objectForKey:@"price"] doubleValue];
        int quantity = [[dict objectForKey:@"quantity"] integerValue];
        for(int i = 0; i < quantity ;i ++){
            [updatedOrder addDish:tmpDish];
        }
        if ([user.pastOrder getQuantityOfDishByID:tmpDish.ID] != quantity){
            changed = TRUE;
        }
    }
    if([updatedOrder getTotalPrice] != [user.pastOrder getTotalPrice] || [updatedOrder getTotalQuantity] != [user.pastOrder getTotalQuantity]){
        changed = TRUE;
    }
    if(changed){
        user.pastOrder = updatedOrder;
    }
    return changed;
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
    [self connectSocket];
}


#pragma mark - Background task tracking test
- (void) beginBackgroundUpdateTask
{
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self beginBackgroundUpdateTask];
        
        NSLog(@"%@ starting background task %lu", self, (unsigned long)self.bgTask);
        [self initLocationManager];
        [self.locationManager stopUpdatingLocation];
        if([[User sharedInstance].userDefault boolForKey:KEY_FOR_SHOW_TUT_DEFAULT]){
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
        [self.mixpanel track:@"Usage Ends" properties:@{@"time": [NSDate date]}];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60 * 5
                                                      target:self
                                                    selector:@selector(startTrackingLocation)
                                                    userInfo:nil
                                                     repeats:YES];
        NSLog(@"%@ ending background task %lu", self, (unsigned long)self.bgTask);

        [self endBackgroundUpdateTask];
    });
    
    NSLog(@"%@ dispatched background task %lu", self, (unsigned long)self.bgTask);
}

#pragma mark - Push notifications

//- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
//    [self.mixpanel.people addPushDeviceToken:devToken];
//}
//
//- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
//#if TARGET_IPHONE_SIMULATOR
//    NSLog(@"%@ push registration error is expected on simulator", self);
//#else
//    NSLog(@"%@ push registration error: %@", self, err);
//#endif
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    // Show alert for push notifications recevied while the app is running
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                    message:userInfo[@"aps"][@"alert"]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
//}


@end
