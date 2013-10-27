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
    MenuListCell *cell = (MenuListCell *)[tableView
                                      dequeueReusableCellWithIdentifier:@"MenuListCell"];
    
    
	Dish *dish = [self.dishesArray objectAtIndex:indexPath.row];
    
	cell.nameLabel.text = dish.name;
    
	cell.priceLabel.text = [NSString stringWithFormat:@"$%d", dish.price];
    
	cell.descriptionLabel.text = dish.description;
    
    return cell;
}

- (void) loadDishesFromServer{

    NSLog(@"Loading dishes from server...");
    
    self.dishesArray = [NSMutableArray arrayWithCapacity:30]; // Capacity will grow up when there're more elements
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LIST_OUTLETS]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}

// Ajax callback to add one more new item in the table:
- (void)addOutlet:(Dish *)dish
{
	[self.dishesArray addObject:dish];
	NSIndexPath *indexPath =
    [NSIndexPath indexPathForRow:[self.dishesArray count] - 1
                       inSection:0];
    
	[self.tableView insertRowsAtIndexPaths:
     [NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
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
