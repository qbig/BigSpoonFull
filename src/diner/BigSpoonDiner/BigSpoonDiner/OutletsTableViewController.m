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

    return cell;
}

- (void) loadOutletsFromServer{
    
    NSLog(@"Loading outlets from server...");

    self.outletsArray = [NSMutableArray arrayWithCapacity:30]; // Capacity will grow up when there're more elements
    
    // Make ajax calls to the server and get the list of outlets
    // And call the ajax callback: - (void)addOutlet:(Outlet *)Outlet
    // We could use  [self.tableView reloadData] but it looks nicer to insert the new row with an animation. 
    
    // Test data:
    
    Outlet *newOutlet = [[Outlet alloc] init];
    
    newOutlet.imgURL = [[NSURL alloc] initWithString:  @"http://profile.ak.fbcdn.net/hprofile-ak-prn1/c142.91.546.546/s160x160/47854_556693471032572_2024581657_n.jpg"];
    newOutlet.name = @"Food For Thought";
    newOutlet.address = @"#3-05 Habourfront Tower";
    newOutlet.phoneNumber = @"8796 0493";
    newOutlet.operatingHours = @"9:30am - 12:00am";
    [self.outletsArray addObject:newOutlet];
    
    Outlet *newOutlet2 = [[Outlet alloc] init];
    
    newOutlet2.imgURL = [[NSURL alloc] initWithString:  @"http://profile.ak.fbcdn.net/hprofile-ak-frc1/c29.29.363.363/s160x160/999357_391637284290743_2024655580_n.jpg"];
    newOutlet2.name = @"Si Chuan Beef Noodle";
    newOutlet2.address = @"#2-08 Serangoon Rd";
    newOutlet2.phoneNumber = @"9879 8569";
    newOutlet2.operatingHours = @"8:30am - 9:00am";
    [self.outletsArray addObject:newOutlet2];
    
    return;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LIST_OUTLETS]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

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
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:_responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //        for (id key in [json allKeys]){
    //            NSString* obj =(NSString *) [json objectForKey: key];
    //            NSLog(obj);
    //        }
    
    switch (statusCode) {
            
            // 200 Okay
        case 200:{
            
            NSString* email =[json objectForKey:@"email"];
            NSString* firstName = [json objectForKey:@"first_name"];
            NSString* lastName = [json objectForKey:@"last_name"];
            NSString* password = [json objectForKey:@"password"];
            NSString* auth_token = [json objectForKey:@"auth_token"];
            
            
            User *user = [User sharedInstance];
            user.firstName = firstName;
            user.lastName = lastName;
            user.email = email;
            user.auth_token = auth_token;
            
            NSLog(@"New user created:");
            NSLog(@"FirstName: %@, LastName: %@", firstName, lastName);
            NSLog(@"Email: %@", email);
            NSLog(@"Pwd: %@", password);
            NSLog(@"Auth_token: %@", auth_token);
            
            [self performSegueWithIdentifier:@"SegueFromAuthToOutlet" sender:self];
            
            
            break;
        }
            
        default:{
            
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
    NSLog(@"NSURLCoonection encounters error at creating users.");
}


// Ajax callback to add one more new item in the table:
- (void)addOutlet:(Outlet *)Outlet
{
	[self.outletsArray addObject:Outlet];
	NSIndexPath *indexPath =
    [NSIndexPath indexPathForRow:[self.outletsArray count] - 1
                       inSection:0];
    
	[self.tableView insertRowsAtIndexPaths:
     [NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueFromOutletsToMenu"]) {
		MenuViewController *menuViewController = segue.destinationViewController;
		menuViewController.delegate = self;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Outlet *outlet = [self.outletsArray objectAtIndex:selectedIndexPath.row];
        menuViewController.outlet = outlet;
        
	} else{
        NSLog(@"Segureee in the outletsViewController cannot assign delegate to its segue. Segue identifier: %@", segue.identifier);
    }
}

@end
