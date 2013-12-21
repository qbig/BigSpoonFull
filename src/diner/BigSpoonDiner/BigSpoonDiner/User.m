//
//  User.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize currentOutlet;
@synthesize validTableIDs;
@synthesize currentOrder;
@synthesize pastOrder;

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
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"RetrievedNewDishesAndTableInfo" object:json];
                // [self handleJsonWithDishesAndTableInfos:json];
             }
                 break;
             case 403:
             default:{
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"DishAndTableRequestNetworkFailure" object:nil];
             }
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"DishAndTableRequestNetworkFailure" object:nil];
     }];
    [operation start];
}


- (void) loadCategoriesFromServer{
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: DISH_CATEGORY_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         long responseCode = [operation.response statusCode];
         switch (responseCode) {
             case 200:
             case 201:{
                 NSArray *categories = (NSArray*)responseObject;
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"RetrievedNewCategoriesInfo" object:categories];
                 //[self parseFromJsonArrToCategories:categories];
                 
             }
                 break;
             case 403:
             default:{
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoriesRequestNetworkFailure" object:nil];
             }
         }
         //NSLog(@"JSON: %@", responseObject);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoriesRequestNetworkFailure" object:nil];
     }];
    [operation start];
}
@end
