//
//  SettingsViewController.m
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 14/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "OrderHistoryViewController.h"
#import "HomeAndSettingsButtonView.h"

@interface OrderHistoryViewController () {
    @private
    int statusCode;
    NSMutableData *orderHistoryDataFromServer;
}

- (void) loadOrderHistoryFromServer;

@end

@implementation OrderHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"HomeAndSettingsButtonView" owner:self options:nil];
    self.topRightButtonsView = [subviewArray objectAtIndex:0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.topRightButtonsView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadOrderHistoryFromServer {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ORDER_HISTORY_URL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue: [@"Token " stringByAppendingString:[User sharedInstance].auth_token] forHTTPHeaderField: @"Authorization"];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    statusCode = [response statusCode];
    orderHistoryDataFromServer = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [orderHistoryDataFromServer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    NSError* error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:orderHistoryDataFromServer options:kNilOptions error:&error];
    NSLog(@"%@", jsonDict);
//    NSArray* outletList = (NSArray*)jsonDict;
//   switch (statusCode) {
//            
//            // 200 Okay
//        case 200:{
//            
//            for (NSDictionary *newOutlet in outletList) {
//                NSDictionary *restaurant = (NSDictionary *)[newOutlet objectForKey:@"restaurant"];
//                NSDictionary *icon = (NSDictionary *)[restaurant objectForKey:@"icon"];
//                NSString *thumbnail = (NSString *)[icon objectForKey:@"thumbnail"];
//                NSURL *imgURL = [[NSURL alloc] initWithString:[BASE_URL stringByAppendingString:thumbnail]];
//                
//                int ID = [[newOutlet objectForKey:@"id"] intValue];
//                double lat = [[newOutlet objectForKey:@"lat"] doubleValue];
//                double lon = [[newOutlet objectForKey:@"lng"] doubleValue];
//                NSString* name = [newOutlet objectForKey:@"name"];
//                NSString* phone = [newOutlet objectForKey:@"phone"];
//                NSString* address = [newOutlet objectForKey:@"address"];
//                NSString* opening = [newOutlet objectForKey:@"opening"];
//                NSString* promotionalText = [newOutlet objectForKey:@"discount"];
//                double gstRate = [[newOutlet objectForKey:@"gst"] doubleValue];
//                double serviceChargeRate = [[newOutlet objectForKey:@"scr"] doubleValue];
//                BOOL isActive = (BOOL)[[newOutlet objectForKey:@"is_active"] boolValue];
//                
//                if (!isActive) {
//                    promotionalText = @"Coming Soon!";
//                }
//                
//                NSLog(@"Outlet id: %d, lat: %f, lon: %f", ID, lat, lon);
//                
//                Outlet *newOutletObject = [[Outlet alloc]initWithImgURL: imgURL
//                                                                   Name: name
//                                                                Address: address
//                                                            PhoneNumber: phone
//                                                        OperationgHours: opening
//                                                               OutletID: ID
//                                                                    lat: lat
//                                                                    lon: lon
//                                                        promotionalText: promotionalText
//                                                                gstRate: gstRate
//                                                      serviceChargeRate: serviceChargeRate
//                                                               isActive: isActive];
//                [self.outletsArray addObject:newOutletObject];
//                
//            }
//            
//            [self.tableView reloadData];
//            
//            break;
//        }
//            
//        default:{
//            
//            NSDictionary* json = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:_responseData
//                                                                                 options:kNilOptions
//                                                                                   error:&error];
//            
//            id firstKey = [[json allKeys] firstObject];
//            
//            NSString* errorMessage =[(NSArray *)[json objectForKey:firstKey] objectAtIndex:0];
//            
//            NSLog(@"Error occurred: %@", errorMessage);
//            
//            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [message show];
//            
//            break;
//        }
//    }
}

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
//                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
//    // Return nil to indicate not necessary to store a cached response for this connection
//    return nil;
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    // The request has failed for some reason!
//    // Check the error var
//    NSLog(@"NSURLCoonection encounters error at retrieving outlits.");
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
//                                                        message:@"Failed to load outlets. Please check your network"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Okay"
//                                              otherButtonTitles: nil];
//    [alertView show];
//}
//
//- (void)MenuViewControllerHomeButtonPressed: (MenuViewController *)controller{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void) viewDidAppear:(BOOL)animated {
    [self loadOrderHistoryFromServer];
}

@end
