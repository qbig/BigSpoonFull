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
    [self loadOutlets];
    
    return YES;
}

- (void)loadOutlets{
    outletsArray = [NSMutableArray arrayWithCapacity:30]; // Capacity will grow up when there're more elements
	Outlet *newOutlet = [[Outlet alloc] init];
    
    // Make ajax calls to the server and get the list of outlets
    
    newOutlet.imgURL = [[NSURL alloc] initWithString:  @"http://profile.ak.fbcdn.net/hprofile-ak-ash4/c224.41.513.513/s160x160/995724_4913971178302_368545087_n.jpg"];
    newOutlet.name = @"Food For Thought";
    newOutlet.address = @"#3-05 Habourfront Tower";
    newOutlet.phoneNumber = @"8796 0493";
    newOutlet.operatingHours = @"9:30am - 12:00am";
    [outletsArray addObject:newOutlet];
    
    newOutlet.imgURL = [[NSURL alloc] initWithString:  @"http://profile.ak.fbcdn.net/hprofile-ak-frc1/s160x160/598607_386531284728364_311542061_a.jpg"];
    newOutlet.name = @"Si Chuan Beef Noodle";
    newOutlet.address = @"#2-08 Serangoon Rd";
    newOutlet.phoneNumber = @"9879 8569";
    newOutlet.operatingHours = @"8:30am - 9:00am";
    [outletsArray addObject:newOutlet];
    
    newOutlet.imgURL = [[NSURL alloc] initWithString:  @"http://profile.ak.fbcdn.net/hprofile-ak-frc1/c29.29.363.363/s160x160/999357_391637284290743_2024655580_n.jpg"];
    newOutlet.name = @"Strictly Pancakes";
    newOutlet.address = @"#3-05 Vivo City";
    newOutlet.phoneNumber = @"9785 0960";
    newOutlet.operatingHours = @"12:00am - 2:00am";
    [outletsArray addObject:newOutlet];
    
    OutletsViewController *outletViewController = (OutletsViewController *)self.window.rootViewController;
    outletViewController.outletsArray = outletsArray;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
