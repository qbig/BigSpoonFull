//
//  MenuTableViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "MenuTableViewController.h"

@interface MenuTableViewController (){
    NSMutableData *_responseData;
    int statusCode;
}

@end

@implementation MenuTableViewController

@synthesize dishesArray;
@synthesize outlet;
@synthesize displayMethod;
@synthesize displayCategory;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadDishesFromServer];
    
    // By default:
    displayCategory = kCategoryBreakfast;
    displayMethod = kMethodPhoto;

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
    return [self.dishesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.displayMethod == kMethodList) {
        
        MenuListCell *cell = (MenuListCell *)[tableView
                                      dequeueReusableCellWithIdentifier:@"MenuListCell"];
    
        Dish *dish = [self.dishesArray objectAtIndex:indexPath.row];
    
        cell.nameLabel.text = dish.name;
    
        cell.priceLabel.text = [NSString stringWithFormat:@"$%d", dish.price];
    
        cell.descriptionLabel.text = dish.description;
        
        return cell;

    }
    
    else {
        
        MenuPhotoCell *cell = (MenuPhotoCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"MenuPhotoCell"];
        
        Dish *dish = [self.dishesArray objectAtIndex:indexPath.row];
        
        //cell.imageView.image =  [UIImage imageWithData:[NSData dataWithContentsOfURL:dish.imgURL]];
        cell.nameLabel.text = dish.name;
        
        cell.priceLabel.text = [NSString stringWithFormat:@"$%d", dish.price];
        
        cell.descriptionLabel.text = dish.description;
        
        return cell;

    }
    
}

- (void) loadDishesFromServer{

    NSLog(@"Loading dishes from server...");
    
    self.dishesArray = [NSMutableArray arrayWithCapacity:30]; // Capacity will grow up when there're more elements
    NSString *appendURL = [NSString stringWithFormat:@"/%d", self.outlet.outletID];
    
    NSString *requestURL = [LIST_OUTLETS stringByAppendingString:appendURL];
    
    NSLog(@"asdfasdfasdfas %@", requestURL);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}

// Ajax callback to add one more new item in the table:
- (void)addDish:(Dish *)dish
{
	[self.dishesArray addObject:dish];
	NSIndexPath *indexPath =
    [NSIndexPath indexPathForRow:[self.dishesArray count] - 1
                       inSection:0];
    
	[self.tableView insertRowsAtIndexPaths:
     [NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
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
    NSDictionary* json = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:_responseData
                                                                         options:kNilOptions
                                                                           error:&error];
    
    //        for (id key in [json allKeys]){
    //            NSString* obj =(NSString *) [json objectForKey: key];
    //            NSLog(obj);
    //        }
    
    switch (statusCode) {
            
        // 200 Okay
        case 200:{
            
            NSArray *dishes = (NSArray *)[json objectForKey:@"dishes"];
            
            for (NSDictionary *newDish in dishes) {
                
                NSDictionary *photo = (NSDictionary *)[newDish objectForKey:@"photo"];
                NSString *thumbnail = (NSString *)[photo objectForKey:@"thumbnail"];
               
                NSURL *imgURL = [[NSURL alloc] initWithString:[BASE_URL stringByAppendingString:thumbnail]];
                
                NSArray *categories = (NSArray *)[newDish objectForKey:@"categories"];
                NSMutableArray *categoryIDs = [[NSMutableArray alloc]init];
                
                for (NSDictionary *newCategory in categories) {
                    int integerValue = [[newCategory objectForKey:@"id"] intValue];
                    [categoryIDs addObject: [[NSNumber alloc] initWithInt: integerValue]];
                }
                
                int ID = [[newDish objectForKey:@"id"] intValue];
                NSString* name = [newDish objectForKey:@"name"];
                int pos = [[newDish objectForKey:@"pos"] intValue];
                NSString* desc = [newDish objectForKey:@"desc"];
                
                NSString* startTime = [newDish objectForKey:@"start_time"];
                NSString* endTime = [newDish objectForKey:@"end_time"];
                
                int price = [[newDish objectForKey:@"price"] intValue];
                int quantity = [[newDish objectForKey:@"quantity"] intValue];
                
                Dish *newDishObject = [[Dish alloc]initWithName:name
                                                    Description:desc
                                                          Price:price
                                                        Ratings:5
                                                             ID:ID
                                                    categories:categories
                                                         imgURL:imgURL
                                                            pos:pos
                                                      startTime:startTime
                                                        endTime:endTime
                                                       quantity:quantity
                                       ];
                
                [self addDish:newDishObject];
                
            }
            
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)breakfastButtonPressed:(id)sender {
    NSLog(@"breakfastButtonPressed");
}

- (IBAction)mainsButtonPressed:(id)sender {
    NSLog(@"mainButtonPressed");
}

- (IBAction)beveragesButtonPressed:(id)sender {
    NSLog(@"beveragesButtonPressed");
}
- (IBAction)sidesAndSnacksButtonPressed:(id)sender {
    NSLog(@"sidesButtonPressed");
    
}


@end
