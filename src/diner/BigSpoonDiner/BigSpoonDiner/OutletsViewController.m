//
//  OutletsViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "OutletsViewController.h"

@interface OutletsViewController ()

@end

@implementation OutletsViewController

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
    // And make the following into a for loop:
    
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
    
    Outlet *newOutlet3 = [[Outlet alloc] init];
    
    newOutlet3.imgURL = [[NSURL alloc] initWithString:  @"http://profile.ak.fbcdn.net/hprofile-ak-frc1/s160x160/598607_386531284728364_311542061_a.jpg"];
    newOutlet3.name = @"Strictly Pancakes";
    newOutlet3.address = @"#3-05 Vivo City";
    newOutlet3.phoneNumber = @"9785 0960";
    newOutlet3.operatingHours = @"12:00am - 2:00am";
    [self.outletsArray addObject:newOutlet3];
    
    Outlet *newOutlet4 = [[Outlet alloc] init];
    
    newOutlet4.imgURL = [[NSURL alloc] initWithString:  @"http://profile.ak.fbcdn.net/hprofile-ak-ash3/c48.48.604.604/s160x160/561871_10151561141968038_385738663_n.jpg"];
    newOutlet4.name = @"Indian Food Awesome";
    newOutlet4.address = @"306 Hello World";
    newOutlet4.phoneNumber = @"9785 5487";
    newOutlet4.operatingHours = @"8:00am - 2:00am";
    [self.outletsArray addObject:newOutlet4];
    
    Outlet *newOutlet5 = [[Outlet alloc] init];
    
    newOutlet5.imgURL = [[NSURL alloc] initWithString:  @"http://profile.ak.fbcdn.net/hprofile-ak-ash4/c132.0.828.828/s160x160/999396_10151861384788793_1043357523_n.jpg"];
    newOutlet5.name = @"Food Style";
    newOutlet5.address = @"#03-05 Array Plazz";
    newOutlet5.phoneNumber = @"9863 5487";
    newOutlet5.operatingHours = @"11:00am - 2:00am";
    [self.outletsArray addObject:newOutlet5];
    
}

- (void)MenuViewControllerHomeButtonPressed: (MenuViewController *)controller{
    NSLog(@"Hellooo");
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
    if ([segue.identifier isEqualToString:@"FromOutletsToMenu"]) {
		MenuViewController *menuViewController = segue.destinationViewController;
		menuViewController.delegate = self;
	} else{
        NSLog(@"Segure in the outletsViewController cannot assign delegate to its segue");
    }
}


@end
