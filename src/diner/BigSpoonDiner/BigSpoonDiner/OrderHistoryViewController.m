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
    UIActivityIndicatorView *indicator;
}

- (void) loadOrderHistoryFromServer;

@end

@implementation OrderHistoryViewController
@synthesize  suggestionLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initActivityIndicator
{
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initActivityIndicator];
    [self.suggestionLabel setFont: [UIFont fontWithName:@"copyfonts.com_segoe_ui_light" size:8]];
    [self loadOrderHistoryFromServer];
    [[Mixpanel sharedInstance] track: @"User reach History View"];
    [TestFlight passCheckpoint:@"CheckPoint:User Checking Past Order"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) loadOrderHistoryFromServer {
    [indicator startAnimating];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ORDER_HISTORY_URL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue: [@"Token " stringByAppendingString:[User sharedInstance].authToken] forHTTPHeaderField: @"Authorization"];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    statusCode = [response statusCode];
    orderHistoryDataFromServer = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [orderHistoryDataFromServer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    NSError* error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:orderHistoryDataFromServer options:kNilOptions error:&error];
    NSLog(@"jsonDict = %@", jsonDict);
    NSArray* pastOrdersList = (NSArray*)jsonDict;
    switch (statusCode) {
        case 200:{
            [self.orderHistoryScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            int pastOrderCount = 0;
            CGFloat scrollViewHeight = 0.0f;
            for (NSDictionary *pastOrder in [pastOrdersList reverseObjectEnumerator]) {
                NSString *order_time = [pastOrder objectForKey:@"order_time"];
                NSDictionary *outlet = [pastOrder objectForKey:@"outlet"];
                NSString *outletName = [outlet objectForKey:@"name"];
                NSArray* meals = (NSArray*)
                [pastOrder objectForKey:@"orders"];
                CGRect frame;
                frame.origin.x = 0;
                PastOrderView *view = [[PastOrderView alloc] initAtIndex:pastOrderCount];
                view.restaurantNameLabel.text = outletName;
                view.orderTime.text = order_time;
                view.meals = [NSArray arrayWithArray:meals];
                view.pastOrderOutletId = [(NSString*)[outlet objectForKey:@"id"] integerValue];
                [self.orderHistoryScrollView addSubview:view];
                scrollViewHeight += view.frame.size.height;
                pastOrderCount ++;
            }
            [self.orderHistoryScrollView setContentSize:(CGSizeMake(self.orderHistoryScrollView.frame.size.width, scrollViewHeight))];
            break;
        }
        default: {
            @try {
                NSDictionary* json = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:orderHistoryDataFromServer options:kNilOptions error:&error];
                id firstKey = [[json allKeys] firstObject];
                NSString* errorMessage =[(NSArray *)[json objectForKey:firstKey] objectAtIndex:0];
                NSLog(@"Error occurred: %@", errorMessage);
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [message show];
                break;
            }
            @catch (NSException *exception) {
                CLS_LOG(@"Loading history issue: %@", exception);
            }

        }
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"NSURLCoonection encounters error while retreiving past orders.");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Failed to load outlets. Please check your network" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alertView show];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (IBAction)showEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        // Email Subject
        NSString *emailTitle = @"Hello BigSpoon!";
        // Email Content
        NSString *messageBody = @"";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@"jay@bigspoon.sg"];
        NSArray *toCCRecipents = [NSArray arrayWithObject:@"leon@bigspoon.sg"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        [mc setCcRecipients:toCCRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thanks for your feedback"
                                                            message:@"Feel free to drop us a message at jay@bigspoon.sg"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
    
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
