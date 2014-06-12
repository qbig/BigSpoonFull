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
        sharedInstance.tableID = -1;
        if(sharedInstance.currentOrder == nil ){
            sharedInstance.currentOrder = [[Order alloc] init];
        }
        if(sharedInstance.pastOrder == nil) {
            sharedInstance.pastOrder = [[Order alloc] init];
        }
       
    });
    return sharedInstance;
}

- (User* ) init {
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attemptToUpdateOrder) name:FB_TOKEN_VERIFIED object:nil];
    return  [super init];
}

#pragma mark FB Login Methods
- (void)attemptToLoginToFB {
    
    if (FBSession.activeSession.isOpen) {
        NSLog(@"FBSession.activeSession.isOpen IS open!");
        // check token validity and login successfully
        [[NSNotificationCenter defaultCenter] postNotificationName:FB_SESSION_IS_OPEN object:self];
        [[Mixpanel sharedInstance] track:@"FB Login: Session open, notification sent. Start Token Validation"];
        [self checkTokenValidity];
    }else{
        NSLog(@"FBSession.activeSession.isOpen NOT open!");
        [[Mixpanel sharedInstance] track:@"FB Login: Session closed. Try openning"];
        [self openSession];
    }
}

- (void) checkTokenValidity {

    if(self.authToken != nil && [[self userDefault] boolForKey: self.authToken]){
        [[NSNotificationCenter defaultCenter] postNotificationName:FB_TOKEN_VERIFIED object:self];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: USER_LOGIN_WITH_FB]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:[FBSession.activeSession accessTokenData].accessToken forKey: @"access_token"];
    [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"FB Login: checking token: %@", [FBSession.activeSession accessTokenData].accessToken]];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    request.HTTPBody = jsonData;
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    // add "text/html" as acceptable return type
    NSMutableSet *acceptableTypes = [[NSMutableSet alloc] initWithSet: operation.responseSerializer.acceptableContentTypes];
    [acceptableTypes addObject:@"text/html"];
    operation.responseSerializer.acceptableContentTypes = acceptableTypes;
    
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         long responseCode = [operation.response statusCode];
         switch (responseCode) {
             case 200:
             case 201:{
                 NSDictionary* json = (NSDictionary*)responseObject;
                 NSString* email =[json objectForKey:@"email"];
                 NSString* firstName = [json objectForKey:@"first_name"];
                 NSString* lastName = [json objectForKey:@"last_name"];
                 NSString* auth_token = [json objectForKey:@"auth_token"];
                 NSString* profilePhotoURL = [json objectForKey:@"avatar_url"];
                 Mixpanel *mixpanel = [Mixpanel sharedInstance];
                 [mixpanel identify:mixpanel.distinctId];
                 [mixpanel createAlias:email
                         forDistinctID:mixpanel.distinctId];
                 [mixpanel registerSuperProperties:@{@"First Name": firstName,
                                                     @"Last Name" : lastName,
                                                     @"Email" : email
                                                     }];
                 [mixpanel.people set:@"$email" to:email];
                 
                 User *user = [User sharedInstance];
                 user.firstName = firstName;
                 user.lastName = lastName;
                 user.email = email;
                 user.authToken = auth_token;
                 [[[User sharedInstance] userDefault] setBool:true forKey:auth_token];
                 user.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: profilePhotoURL]]];
                 [[NSNotificationCenter defaultCenter] postNotificationName:FB_TOKEN_VERIFIED object:self];
                 [[Mixpanel sharedInstance] track:@"FB Login: Token verified. About to move to outletView"];
                 NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                 
                 // Set
                 [prefs setObject:firstName forKey:@"firstName"];
                 [prefs setObject:lastName forKey:@"lastName"];
                 [prefs setObject:email forKey:@"email"];
                 [prefs setObject:profilePhotoURL forKey:@"profilePhotoURL"];
                 [prefs synchronize];
                 [SSKeychain setPassword:auth_token forService:@"BigSpoon" account:email];
             }
                 break;
             case 403:
             default:{
                 [[Mixpanel sharedInstance] track:[NSString stringWithFormat: @"FB Login: TokenVerifying failed with code %ld", responseCode]];
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEW_DISH_INFO_FAILED object:nil];
             }
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (error != nil){
             [[Mixpanel sharedInstance] track: [NSString stringWithFormat:@"FB Login: TokenVerifying failed(operation failed), Error: %@", [error description]]];
         } else {
             [[Mixpanel sharedInstance] track: @"FB Login: TokenVerifying failed(operation failed)"];
         }
         
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_NEW_DISH_INFO_FAILED object:nil];
     }];
    [operation start];
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error{
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"Successfully logged in with Facebook");
            if (FBSession.activeSession.isOpen) {
                NSLog(@"YAY! Finally Become open!");
                [[NSNotificationCenter defaultCenter] postNotificationName:FB_SESSION_IS_OPEN object:self];
                [[Mixpanel sharedInstance] track:@"Facebook login sucess"];
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
            [[Mixpanel sharedInstance] track:@"Facebook login failure"];
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
         if (FBSession.activeSession.isOpen) {
             NSLog(@"FBSession.activeSession.isOpen IS open!");
             // check token validity and login successfully
             [[NSNotificationCenter defaultCenter] postNotificationName:FB_SESSION_IS_OPEN object:self];
             [[Mixpanel sharedInstance] track:@"FB Login: Session open, notification sent. Start Token Validation"];
             [self checkTokenValidity];
         }
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
                 //[[NSUserDefaults standardUserDefaults] setObject: json forKey: [NSString stringWithFormat:@"%@%d",OUTLET_INFO_FOR_ID_PREFIX ,outletID]];
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


#pragma mark Geo Location

- (BOOL) isUserOutsideRestaurant{
    
    if([self isUserLocation:[User sharedInstance].userLocation WithinMeters:50 +[User sharedInstance].userLocation.horizontalAccuracy * 2 OfLatitude:self.currentOutlet.lat AndLongitude:self.currentOutlet.lon]){
        [[Mixpanel sharedInstance] track:@"Action Success: Location Inbound"];
    } else {
        [[Mixpanel sharedInstance] track:@"Action Failed: Location Out of bound"];
    }
    return ![self isUserLocation:[User sharedInstance].userLocation WithinMeters:50 +[User sharedInstance].userLocation.horizontalAccuracy * 2 OfLatitude:self.currentOutlet.lat AndLongitude:self.currentOutlet.lon];
}

- (BOOL) isLocationServiceDisabled{
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied;
}

- (BOOL) isUserLocation:(CLLocation *)userLocation WithinMeters:(double)radius OfLatitude:(double)lat AndLongitude:(double)lon
{
    if (userLocation == nil){
        [[Mixpanel sharedInstance] track:@"Location Check Failed: No location available"];
        return false;
    }
    if ([self meAtPgpBusStop:userLocation WithinMeters:1500]){
        [[Mixpanel sharedInstance] track:@"Location Check Success(Admin): Admin condition met"];
        return true;
    }
    
    CLLocation *outletLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    CLLocationDistance distance = [userLocation distanceFromLocation:outletLocation];
    if (distance <= radius) {
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Location Check Succeeded: In bound, (limit: %g, actual: %g)",radius, distance]];
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Actual Postion:(lat: %g, long: %g)",userLocation.coordinate.latitude, userLocation.coordinate.longitude]];
        return true;
    } else {
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Location Check Failed: Out of bound, (limit: %g, actual: %g)",radius, distance]];
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Actual Postion:(lat: %g, long: %g)",userLocation.coordinate.latitude, userLocation.coordinate.longitude]];
        return false;
    }
}

- (BOOL) meAtPgpBusStop :(CLLocation *)userLocation WithinMeters:(double)radius{
    // assuming location available
    CLLocation *pgpBusStopLocation = [[CLLocation alloc] initWithLatitude:1.292026 longitude:103.780304];
    CLLocation *pgp5Location = [[CLLocation alloc] initWithLatitude:1.293208 longitude:103.778376];
    
    CLLocationDistance distanceFromBusStop = [userLocation distanceFromLocation:pgpBusStopLocation];
    CLLocationDistance distanceFromPgp5 = [userLocation distanceFromLocation:pgp5Location];
    User *user = [User sharedInstance];
    if ((distanceFromBusStop <= radius && distanceFromPgp5 <= radius && [user.email isEqualToString:@"qiaoliang89@yahoo.com.cn"]) || [user.email isEqualToString:@"jay.tjk@gmail.com"]) {
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Location Check Succeeded: In bound, (dist from pgp bus stop: %g, dist from pgp 5: %g)",distanceFromBusStop, distanceFromPgp5]];
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Actual Postion:(lat: %g, long: %g)",userLocation.coordinate.latitude, userLocation.coordinate.longitude]];
        return true;
    } else {
        return false;
    }
}

- (void) attemptToUpdateOrder {
    @try {
        [self updateOrder];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
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
    self.updatePending = NO;
    NSDictionary *ordersDict = [json objectForKey:@"orders"];
    NSDictionary *outletInfo = [json objectForKey:@"outlet"];
    User *user = [User sharedInstance];
    user.currentOutletID = [[outletInfo objectForKey:@"id"] intValue];
    Order *updatedOrder = [[Order alloc] init];
    for(NSDictionary * dict in ordersDict){
        NSDictionary* dishDic = [dict objectForKey:@"dish"];
        Dish *tmpDish = [[Dish alloc] init];
        tmpDish.name = [dishDic objectForKey:@"name"];
        tmpDish.ID = [[dishDic objectForKey:@"id"] integerValue];
        tmpDish.price = [[dishDic objectForKey:@"price"] doubleValue];
        int quantity = [[dict objectForKey:@"quantity"] integerValue];
        
        [updatedOrder.dishes addObject:tmpDish];
        [updatedOrder.quantity addObject:[NSNumber numberWithInt: quantity]];
        int dishIndex = [updatedOrder.dishes count] - 1 ;
        Dish *existingPastOrderDish;
        if(dishIndex <= [self.pastOrder.dishes count] - 1 && [self.pastOrder.dishes count] != 0){
            existingPastOrderDish = (Dish *) [self.pastOrder.dishes objectAtIndex:dishIndex];
        } else {
            self.updatePending = YES;
        }
        
        if(existingPastOrderDish != nil && (existingPastOrderDish.ID != tmpDish.ID || existingPastOrderDish.quantity != tmpDish.quantity)){
            self.updatePending = YES;
        }
        
        NSString *modifierStr = [dict objectForKey:@"modifier_json"];
        if ( ! (modifierStr == (id)[NSNull null] || modifierStr.length == 0 )){
            NSError* error;
            NSDictionary *modifierAnswer = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:[modifierStr dataUsingEncoding:NSUTF8StringEncoding ]options:0 error:&error];
            [updatedOrder setModifierAnswer:modifierAnswer atIndex: dishIndex];
        }
    }

    if(self.updatePending){
        user.pastOrder = updatedOrder;
    }
    return self.updatePending;
}

- (void) closeCurrentSession{
    [User sharedInstance].tableID = -1;
    [User sharedInstance].pastOrder = [[Order alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_ORDER_UPDATE object:nil];
}

- (BOOL) isLocation:(CLLocation *)locationA SameAsLocation:(CLLocation *)locationB {
    if ((locationA.coordinate.latitude == locationB.coordinate.latitude) && (locationA.coordinate.longitude == locationB.coordinate.longitude)) {
        return true;
    }
    else {
        return false;
    }
}

@end
