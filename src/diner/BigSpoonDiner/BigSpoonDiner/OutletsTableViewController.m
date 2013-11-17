//
//  OutletsViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "OutletsTableViewController.h"

@interface OutletsTableViewController (){
    NSMutableData *_responseData;
    int statusCode;
}

@end

@implementation OutletsTableViewController

@synthesize outletsArray;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadOutletsFromServer];
    
    self.isSocketConnected = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.outletsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OutletCell *cell = (OutletCell *)[tableView
                             dequeueReusableCellWithIdentifier:@"OutletCell"];
    

	Outlet *outlet = [self.outletsArray objectAtIndex:indexPath.row];
    // If the cells are not sub-classes, we can use tags to retrieve the element in the cell:
	//UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    
    // For optimization purpose:
    // URLImageView *imageView = [[URLImageView alloc] init];
    // [imageView startLoading: [outlet.imgURL absoluteString]];
    
    cell.outletPhoto.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: [outlet.imgURL absoluteString]]]];
    
	cell.name.text = outlet.name;
    
	cell.address.text = outlet.address;
    
	cell.phoneNumber.text = outlet.phoneNumber;
    
	cell.operatingHours.text = outlet.operatingHours;
    
    cell.promotionTextLabel.text = outlet.promotionalText;

    return cell;
}

- (void) loadOutletsFromServer{
    
    NSLog(@"Loading outlets from server...");

    self.outletsArray = [NSMutableArray arrayWithCapacity:30]; // Capacity will grow up when there're more elements
    
    // Make HTTP request to the server and get the list of outlets
    // And call the HTTP callback: - (void)addOutlet:(Outlet *)Outlet
    // We could use  [self.tableView reloadData] but it looks nicer to insert the new row with an animation. 
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LIST_OUTLETS]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    statusCode = [response statusCode];
    
    //NSDictionary* headers = [response allHeaderFields];
    
    NSLog(@"response code: %d",  statusCode);
    
    _responseData = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //parse out the json data
    
    NSError* error;
    NSArray* outletList = (NSArray*) [NSJSONSerialization JSONObjectWithData:_responseData
                                                                     options:kNilOptions
                                                                       error:&error];
    //        for (id key in [json allKeys]){
    //            NSString* obj =(NSString *) [json objectForKey: key];
    //            NSLog(obj);
    //        }
    
    switch (statusCode) {
            
        // 200 Okay
        case 200:{
            
            for (NSDictionary *newOutlet in outletList) {
                NSDictionary *restaurant = (NSDictionary *)[newOutlet objectForKey:@"restaurant"];
                NSDictionary *icon = (NSDictionary *)[restaurant objectForKey:@"icon"];
                NSString *thumbnail = (NSString *)[icon objectForKey:@"thumbnail"];
                NSURL *imgURL = [[NSURL alloc] initWithString:[BASE_URL stringByAppendingString:thumbnail]];
                
                int ID = [[newOutlet objectForKey:@"id"] intValue];
                double lat = [[newOutlet objectForKey:@"lat"] doubleValue];
                double lon = [[newOutlet objectForKey:@"lng"] doubleValue];
                NSString* name = [newOutlet objectForKey:@"name"];
                NSString* phone = [newOutlet objectForKey:@"phone"];
                NSString* address = [newOutlet objectForKey:@"address"];
                NSString* opening = [newOutlet objectForKey:@"opening"];
                NSString* promotionalText = [newOutlet objectForKey:@"discount"];
                double gstRate = [[newOutlet objectForKey:@"gst"] doubleValue];
                double serviceChargeRate = [[newOutlet objectForKey:@"scr"] doubleValue];
                BOOL isActive = (BOOL)[[newOutlet objectForKey:@"is_active"] boolValue];
                
                if (!isActive) {
                    promotionalText = @"Coming Soon!";
                }
                
                NSLog(@"Outlet id: %d, lat: %f, lon: %f", ID, lat, lon);
                
                Outlet *newOutletObject = [[Outlet alloc]initWithImgURL: imgURL
                                                                   Name: name
                                                                Address: address
                                                            PhoneNumber: phone
                                                        OperationgHours: opening
                                                               OutletID: ID
                                                                    lat: lat
                                                                    lon: lon
                                                        promotionalText: promotionalText
                                                                gstRate: gstRate
                                                      serviceChargeRate: serviceChargeRate
                                                               isActive: isActive];
                [self.outletsArray addObject:newOutletObject];

            }
            
            [self.tableView reloadData];
            
            break;
        }
            
        default:{
            
            NSDictionary* json = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:_responseData
                                                                             options:kNilOptions
                                                                               error:&error];
            
            id firstKey = [[json allKeys] firstObject];
            
            NSString* errorMessage =[(NSArray *)[json objectForKey:firstKey] objectAtIndex:0];
            
            NSLog(@"Error occurred: %@", errorMessage);
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message show];
            
            break;
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"NSURLCoonection encounters error at retrieving outlits.");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Failed to load outlets. Please check your network"
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles: nil];
    [alertView show];
}

- (void)MenuViewControllerHomeButtonPressed: (MenuViewController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    Outlet *outlet = [self.outletsArray objectAtIndex:indexPath.row];
    
    // Deselect the row. Otherwise it will remain being selected.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (outlet.isActive) {
        NSLog(@"Is Active haha!!");
        NSLog(@"Row: %d, ID: %d", indexPath.row, outlet.outletID);
        [self performSegueWithIdentifier:@"SegueFromOutletsToMenu" sender:self];
    } else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"The restaurant is coming soon"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueFromOutletsToMenu"]) {
		MenuViewController *menuViewController = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Outlet *outlet = [self.outletsArray objectAtIndex:selectedIndexPath.row];
        menuViewController.outlet = outlet;
        menuViewController.delegate = self;
        
        if (outlet.outletID == self.outletIDOfPreviousSelection) {
            
            NSLog(@"In outlets list: going back to a previous page with selected items");
            
            // Assign the history to the outlet:
            menuViewController.currentOrder = self.currentOrder;
            menuViewController.pastOrder = self.pastOrder;
            menuViewController.tableID = self.tableIDOfPreviousSelection;
            
            // Erase self data. If the user exits from the outlet, these info will be set by delegate.
            self.currentOrder = nil;
            self.pastOrder = nil;
            self.tableIDOfPreviousSelection = -1;
            self.outletIDOfPreviousSelection = -1;
            
        } else{
            
            NSLog(@"In outlets list: opening a new page with no selected items");
            
        }
        
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Home" style: UIBarButtonItemStyleBordered target: nil action: nil];
        [[self navigationItem] setBackBarButtonItem: newBackButton];
        
	} else{
        NSLog(@"Segureee in the outletsViewController cannot assign delegate to its segue. Segue identifier: %@", segue.identifier);
    }
}

#pragma mark - Delegate

- (void) exitMenuListWithCurrentOrder: (Order *) currentOrder
                            PastOrder: (Order *) pastOrder
                             OutletID: (int) outletID
                           andTableID: (int) tableID {
    self.currentOrder = currentOrder;
    self.pastOrder = pastOrder;
    self.outletIDOfPreviousSelection = outletID;
    self.tableIDOfPreviousSelection = tableID;
}

#pragma mark - Socket Connection

// Delegate method which will be called by menuViewController
- (void) userDidMakeRequests{
    
    if (!self.isSocketConnected) {
        self.isSocketConnected = YES;

        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)SOCKET_URL, SOCKET_PORT, &readStream, &writeStream);
        self.inputStream = (__bridge NSInputStream *)readStream;
        self.outputStream = (__bridge NSOutputStream *)writeStream;
        
        [self.inputStream setDelegate:self];
        [self.outputStream setDelegate:self];
        
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        
        // Subscribe
        User *user = [User sharedInstance];
        NSString *response  = [NSString stringWithFormat:@"subscribe:u_%@", user.auth_token];
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [self.outputStream write:[data bytes] maxLength:[data length]];
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    switch (eventCode) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            NSLog(@"Stream has byte available");
            if (aStream == self.inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                                message:output
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"Got it."
                                                                      otherButtonTitles: nil];
                            [alertView show];
                        }
                    }
                }
            }

			break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Stream: Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
			break;
            
		default:
			NSLog(@"Stream: Unknown event");
	}
}

@end
