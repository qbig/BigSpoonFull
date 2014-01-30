//
//  User.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "User.h"
#import "SSKeychain.h"

@implementation User
@synthesize currentOutlet;
@synthesize validTableIDs;

+ (User *)sharedInstance
{
    static User *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[User alloc] init];
        sharedInstance.userDefault = [NSUserDefaults standardUserDefaults];
        sharedInstance.email =[sharedInstance.userDefault objectForKey:@"email"];
        sharedInstance.firstName = [sharedInstance.userDefault objectForKey:@"first_name"];
        sharedInstance.lastName = [sharedInstance.userDefault objectForKey:@"last_name"];
        sharedInstance.authToken = [sharedInstance.userDefault objectForKey:@"auth_token"];

        if(sharedInstance.currentOrder == nil ){
            sharedInstance.currentOrder = [[Order alloc] init];
        }
        if(sharedInstance.pastOrder == nil) {
            sharedInstance.pastOrder = [[Order alloc] init];
        }
    });
    return sharedInstance;
}

#pragma mark FB Login Methods
- (void)attemptToLoginToFB {
    
    if (FBSession.activeSession.isOpen) {
        NSLog(@"FBSession.activeSession.isOpen IS open!");
        // check token validity and login successfully
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FBSessionIsOpen" object:self];
    }else{
        NSLog(@"FBSession.activeSession.isOpen NOT open!");
        [self openSession];
    }
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error{
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"Successfully logged in with Facebook");
            if (FBSession.activeSession.isOpen) {
                NSLog(@"YAY! Finally Become open!");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FBSessionIsOpen" object:self];
            } else{
                NSLog(@"Nope not yet");
            }
        }
            break;
        case FBSessionStateClosed:{
            NSLog(@"FBSessionStateClosed");
        }
            break;
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            NSLog(@"Failed logging with Facebook");
            [FBSession.activeSession closeAndClearTokenInformation];
            
            break;
        default:
            NSLog(@"Other cases");
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSession
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", @"basic_info", nil];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,FBSessionState state, NSError *error) {
         
         
         [self sessionStateChanged:session state:state error:error];
         
         FBSession.activeSession = session;
     }];
}

#pragma mark Loading Outlet Dish & Categories & Table info Methods
- (void) loadDishesAndTableInfosFromServerForOutlet: (int) outletID{
    
    NSLog(@"Loading dishes from server...using AFNetworking..");
    NSString *requestURL = [NSString stringWithFormat:@"%@/%d", LIST_OUTLETS, outletID];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: requestURL]];
    [request setValue: [@"Token " stringByAppendingString:self.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         long responseCode = [operation.response statusCode];
         switch (responseCode) {
             case 200:
             case 201:{
                 NSDictionary* json = (NSDictionary*)responseObject;
                 [[NSUserDefaults standardUserDefaults] setObject: json forKey: [NSString stringWithFormat:@"%@%d",OUTLET_INFO_FOR_ID_PREFIX ,outletID]];
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEW_DISH_INFO_RETRIEVED object:json];
             }
                 break;
             case 403:
             default:{
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEW_DISH_INFO_FAILED object:nil];
             }
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEW_DISH_INFO_FAILED object:nil];
     }];
    [operation start];
}

- (void) saveInfoString:(NSString *)info ForKey: (NSString*) key{
    [self.userDefault setObject:info forKey:key];
}

- (NSString *) getInfoStringForKey: (NSString *) key{
    return [self.userDefault objectForKey:key];
}

- (void) saveObject:(id) obj forKey: (NSString*) key{
    [self.userDefault setObject:obj forKey:key];
}

- (id) getObjectForKey: (NSString*) key{
    return [self.userDefault objectForKey:key];
}

- (void) setOutletData: (id) obj forOutletID:(int) outletID{
    [self.userDefault setObject: obj forKey:[NSString stringWithFormat:@"%@%d",OUTLET_INFO_FOR_ID_PREFIX ,outletID]];
}

- (id) getOutletDataWithID: (int) outletID{
    return [self.userDefault objectForKey:[NSString stringWithFormat:@"%@%d",OUTLET_INFO_FOR_ID_PREFIX ,outletID]];
}



@end
