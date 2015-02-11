//
//  AppDelegate.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 12/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "AppDelegate.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTrackingLocation) name:NOTIF_SHOULD_ASK_LOCATION_PERMIT_NOT object:nil];
    if([[User sharedInstance].userDefault boolForKey:KEY_FOR_SHOW_TUT_DEFAULT]){
        // for instance access for geo-point
        [self startTrackingLocation];
    }
    
 //   [Fabric with:@[CrashlyticsKit]];
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
        if (IS_OS_8_OR_LATER) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
        if (newLocation.horizontalAccuracy < 0) {
            return;
        }
        [User sharedInstance].userLocation = newLocation;
 
}

// Failed to get current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorString;
    UIAlertView *alert ;
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"Dear customer, you may want to enable location to use BigSpoon";
            alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            [self.mixpanel track:@"Location Failed: kCLErrorLocationUnknown"];
            break;
        default:
            [self.mixpanel track:@"Location Failed: Default"];
            break;
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self disconnectSocket];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if([[User sharedInstance].userDefault boolForKey:KEY_FOR_SHOW_TUT_DEFAULT]){
        [self initLocationManager];
        [self startTrackingLocation];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self connectSocket];
    [[User sharedInstance] attemptToUpdateOrder];
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
    [self performSelector:@selector(connectSocket) withObject:self afterDelay:1];
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
            [[User sharedInstance] attemptToUpdateOrder];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ORDER_UPDATE object:nil];
        } else if ([messages rangeOfString:SOCKET_IO_TOKEN_BILL_CLOSED].location != NSNotFound){
            // clean user session
            [[User sharedInstance] closeCurrentSession];
        }
        
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
    [self performSelector:@selector(connectSocket) withObject:self afterDelay:1];
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
    [self.locationManager stopUpdatingLocation];
    NSLog(@"%@ dispatched background task %lu", self, (unsigned long)self.bgTask);
}
@end
