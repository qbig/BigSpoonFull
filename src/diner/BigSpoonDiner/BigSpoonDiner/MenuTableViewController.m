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
    self.categoryButtonsArray = [[NSMutableArray alloc] init];
    
    [self loadCategoriesFromServer];
    [self loadDishesFromServer];
    
    // By default:
    self.displayMethod = kMethodPhoto;
    self.displayCategoryID = -1;
    
    // Set the table view to be the same height as the screen:
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGRect frame = self.tableView.frame;
    
    if (fabsf(screenRect.size.height - IPHONE_35_INCH_HEIGHT) < 0.001) {
        NSLog(@"Iphone 3.5 inch screen");

        self.tableView.frame = CGRectMake(frame.origin.x,
                                          frame.origin.y,
                                          frame.size.width,
                                          screenRect.size.height - IPHONE_35_INCH_TABLE_VIEW_OFFSET);
    } else if (fabsf(screenRect.size.height - IPHONE_4_INCH_HEIGHT) < 0.001){
        NSLog(@"Iphone 4 inch screen");

        self.tableView.frame = CGRectMake(frame.origin.x,
                                          frame.origin.y,
                                          frame.size.width,
                                          screenRect.size.height - IPHONE_4_INCH_TABLE_VIEW_OFFSET);
    } else{
        NSLog(@"Error: haha invalid iphone screen height: %f", screenRect.size.height);
        self.tableView.frame = CGRectMake(frame.origin.x,
                                          frame.origin.y,
                                          frame.size.width,
                                          screenRect.size.height - IPHONE_35_INCH_TABLE_VIEW_OFFSET);
    }
    
//    self.tableView.frame = CGRectMake(frame.origin.x,
//                                      frame.origin.y,
//                                      frame.size.width,
//                                      screenRect.size.height - 130);


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//- (void) viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    
//    [self.categoryButtonsHolderView setContentOffset:CGPointZero animated:NO];
//}

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
    NSArray *dishes = [self getDishWithCategory:self.displayCategoryID];
    // Add one at the bottom to avoid from hidden by the bar
    return [dishes count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *dishes = [self getDishWithCategory:self.displayCategoryID];
    
    // The very last one: placeholder to avoid from hidden by the bar:
    if ([indexPath row] == [dishes count]) {
        if (self.displayMethod == kMethodList) {
            MenuListCell *cell = [[MenuListCell alloc]init];
            
            cell.nameLabel.text = @"";
            cell.addButton.tag = -1;
            cell.priceLabel.text = @"";
            cell.descriptionLabel.text = @"";
            
            return cell;
        } else{
            
            MenuPhotoCell *cell = [[MenuPhotoCell alloc] init];
            [cell.addButton setEnabled:NO];
            cell.nameLabel.text = @"";
            cell.addButton.tag = -1;
            cell.priceLabel.text = @"";
            cell.descriptionLabel.text = @"";
            cell.imageView.image = nil;

            return cell;
        }
    }
    
    Dish *dish = [[self getDishWithCategory:self.displayCategoryID] objectAtIndex:indexPath.row];

    if (self.displayMethod == kMethodList) {
        
        MenuListCell *cell = (MenuListCell *)[tableView
                                      dequeueReusableCellWithIdentifier:@"MenuListCell"];
        
        cell.nameLabel.text = dish.name;
        // [cell.nameLabel alignBottom];
        
        // When the button is clicked, we know which one. :)
        cell.addButton.tag = dish.ID;
    
        cell.priceLabel.text = [NSString stringWithFormat:@"%.1f", dish.price];
    
        cell.descriptionLabel.text = dish.description;
        //[cell.descriptionLabel alignTop];
        
        return cell;

    }
    
    else {
        
        MenuPhotoCell *cell = (MenuPhotoCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"MenuPhotoCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // When the button is clicked, we know which one. :)
        cell.addButton.tag = dish.ID;
        
        UIImage *image; // Without cache: = [UIImage imageWithData:[NSData dataWithContentsOfURL:dish.imgURL]];

        
        if ([[ImageCache sharedImageCache] doesExist:dish.imgURL] == true){
            image = [[ImageCache sharedImageCache] getImage:dish.imgURL];
        } else {
            NSData *imageData = [[NSData alloc] initWithContentsOfURL: dish.imgURL];
            image = [[UIImage alloc] initWithData:imageData];
            
            // Add the image to the cache
            [[ImageCache sharedImageCache] addImageWithURL:dish.imgURL andImage:image];
        }
        
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        [cell.imageView setClipsToBounds:YES];
        cell.imageView.autoresizingMask = UIViewAutoresizingNone;
        cell.imageView.image =  image;

        cell.ratingImageView.image = [self imageForRating:dish.ratings];
        
        cell.nameLabel.text = dish.name;
        [cell.nameLabel alignBottom];
        
        
        cell.priceLabel.text = [NSString stringWithFormat:@"%.1f", dish.price];
        
        cell.descriptionLabel.text = dish.description;
        [cell.descriptionLabel alignTop];
        
        return cell;

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Code for dynamically determine the height for cell. Not used
//    NSArray *dishes = [self getDishWithCategory:self.displayCategoryID];
//    Dish *dish;
//    
//    if ([dishes count] == 0) {
//        return 0;
//    } else if(indexPath.row == [dishes count]){
//        dish = [dishes objectAtIndex:0];
//    } else{
//        dish = [dishes objectAtIndex:indexPath.row];
//    }
//    
//    if (self.displayMethod == kMethodList) {
//        
//        if ([dish.name length] > MAX_CHARS_IN_NAME_LABEL_LIST_MENU) {
//            return ROW_HEIGHT_LIST_MENU + LINE_HEIGHT_IN_NAME_LABEL_LIST_MENU;
//        }else{
//            return ROW_HEIGHT_LIST_MENU;
//        }
//        
//    } else if (self.displayMethod == kMethodPhoto){
//        
//        if ([dish.name length] > MAX_CHARS_IN_NAME_LABEL_LIST_MENU) {
//            return ROW_HEIGHT_PHOTO_MENU + LINE_HEIGHT_IN_NAME_LABEL_PHOTO_MENU;
//        } else{
//            return ROW_HEIGHT_PHOTO_MENU;
//        }
//        
//    } else{
//        NSLog(@"Invalid display method");
//        return 100;
//    }
    
    NSArray *dishes = [self getDishWithCategory:self.displayCategoryID];
    if ([indexPath row] == [dishes count]) {
        return HEIGHT_REQUEST_BAR;
    }
    
    if (self.displayMethod == kMethodList) {

            return ROW_HEIGHT_LIST_MENU;
    
    } else if (self.displayMethod == kMethodPhoto){
        
            return ROW_HEIGHT_PHOTO_MENU;
    
    } else{
        NSLog(@"Invalid display method");
        return 0;
    }
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

- (UIImage *)imageForRating:(int)rating
{
	switch (rating)
	{
		case 1: return [UIImage imageNamed:@"1StarSmall@2x.png"];
		case 2: return [UIImage imageNamed:@"2StarsSmall@2x.png"];
		case 3: return [UIImage imageNamed:@"3StarsSmall@2x.png"];
		case 4: return [UIImage imageNamed:@"4StarsSmall@2x.png"];
		case 5: return [UIImage imageNamed:@"5StarsSmall@2x.png"];
	}
	return nil;
}

#pragma mark - Loading Data:

- (void) loadDishesFromServer{

    NSLog(@"Loading dishes from server...");
    
    self.dishesArray = [NSMutableArray arrayWithCapacity:30]; // Capacity will grow up when there're more elements
    NSString *appendURL = [NSString stringWithFormat:@"/%d", self.outlet.outletID];
    
    NSString *requestURL = [LIST_OUTLETS stringByAppendingString:appendURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) loadCategoriesFromServer{
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: DISH_CATEGORY_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        long responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{
                
                NSArray *categories = (NSArray*)responseObject;
                
                int sumOfCategoryButtonWidths = 0;
                int buttonHeight = self.categoryButtonsHolderView.frame.size.height - CATEGORY_BUTTON_OFFSET;
                UIColor *buttonElementColour = [UIColor colorWithRed:CATEGORY_BUTTON_COLOR_RED
                                                              green:CATEGORY_BUTTON_COLOR_GREEN
                                                               blue:CATEGORY_BUTTON_COLOR_BLUE
                                                              alpha:1];
                
                for (NSDictionary *newCategory in categories) {
                    NSNumber *categoryID = (NSNumber *)[newCategory objectForKey:@"id"];
                    NSString *name = [newCategory objectForKey:@"name"];
                    NSString *description = [newCategory objectForKey:@"desc"];
                    
                    DishCategory *newObj = [[DishCategory alloc] initWithID:[categoryID integerValue]
                                                                       name:name
                                                             andDescription:description];
                    // Put the object into dishDategoryArray:
                    [self.dishCategoryArray addObject:newObj];
                    
                    // Add one more category button
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    button.tag = [categoryID integerValue];
                    button.layer.borderColor = buttonElementColour.CGColor;
                    button.layer.borderWidth = CATEGORY_BUTTON_BORDER_WIDTH;

                    [button setTitleColor:buttonElementColour forState:UIControlStateNormal];
                    button.titleLabel.font = [UIFont fontWithName:@"YanaR-Bold" size:20.0];
                    
                    [button addTarget:self
                               action:@selector(dishCategoryButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
                    
                    // Add spaces before and after the title:
                    NSString *buttonTitle = [name stringByAppendingString:@"  "];
                    buttonTitle = [@"  " stringByAppendingString:buttonTitle];
                    [button setTitle:buttonTitle forState:UIControlStateNormal];
                    
                    [self.categoryButtonsHolderView addSubview:button];

                    int buttonWidth = [buttonTitle length] * AVERAGE_PIXEL_PER_CHAR;
                    button.frame = CGRectMake(sumOfCategoryButtonWidths, 0, buttonWidth, buttonHeight);
                    // minus border width so that they will overlap at the border:
                    sumOfCategoryButtonWidths += buttonWidth - CATEGORY_BUTTON_BORDER_WIDTH;
                    
                    [self.categoryButtonsArray addObject:button];
                }
                
                self.categoryButtonsHolderView.contentSize =CGSizeMake(sumOfCategoryButtonWidths + CATEGORY_BUTTON_SCROLL_WIDTH, buttonHeight);
                [self dishCategoryButtonPressed:[self.categoryButtonsArray objectAtIndex:0]];
                
            }
                break;
            case 403:
            default:{
                [self displayErrorInfo: @"Please check your network"];
            }
        }
        //NSLog(@"JSON: %@", responseObject);
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [self displayErrorInfo:operation.responseString];
                                      }];
    [operation start];
}

- (void) displayErrorInfo: (NSString *) info{
    NSLog(@"Error: %@", info);
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Oops"
                              message: info
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}


// HTTP callback to add one more new item in the table:
- (void)addDish:(Dish *)dish
{
    
    // Not used. Because it's view is not aligned properly. Don't know the bug yet.
    
    return;
    
	[self.dishesArray addObject:dish];
    
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dishesArray count] - 1 inSection: 0];
    
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

    switch (statusCode) {
            
        // 200 Okay
        case 200:{
            
            NSArray *dishes = (NSArray *)[json objectForKey:@"dishes"];
            
            for (NSDictionary *newDish in dishes) {
                
                NSDictionary *photo = (NSDictionary *)[newDish objectForKey:@"photo"];
                NSString *thumbnail = (NSString *)[photo objectForKey:@"thumbnail_large"]; //original,thumbnail_large,thumbnail
               
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
                
                double price = [[newDish objectForKey:@"price"] floatValue];
                int quantity = [[newDish objectForKey:@"quantity"] intValue];
                
                int rating = [[newDish objectForKey:@"average_rating"] intValue];
                if (rating == -1) {
                    rating = 0;
                }
                
                Dish *newDishObject = [[Dish alloc]initWithName:name
                                                    Description:desc
                                                          Price:price
                                                        Ratings:rating
                                                             ID:ID
                                                    categories:categoryIDs
                                                         imgURL:imgURL
                                                            pos:pos
                                                      startTime:startTime
                                                        endTime:endTime
                                                       quantity:quantity
                                       ];
                if ([categories count] > 0) {
                    [self.dishesArray insertObject:newDishObject atIndex:0];
                } else{
                    [self.dishesArray addObject:newDishObject];
                }
            }
            
            [self.tableView reloadData];
            
            // Retrieve valid table IDs:
            NSMutableArray *validTableIDs = [[NSMutableArray alloc] init];
            NSArray *tables = (NSArray *)[json objectForKey:@"tables"];
            for (NSDictionary *newTable in tables) {
                NSNumber *tableID = (NSNumber *)[newTable objectForKey: @"id" ];
                [validTableIDs addObject: tableID];
            }
            
            [self.delegate validTableRetrieved:validTableIDs];
            
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
    NSLog(@"NSURLCoonection encounters error at getting dishes.");
    
    NSLog(@"NSURLCoonection encounters error at retrieving outlits.");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Failed to load menu. Please check your network"
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles: nil];
    [alertView show];
}

#pragma mark - Event Listeners

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

- (IBAction)addNewItemButtonClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    int itemID = btn.tag;
    
    NSLog(@"New item added to order list with ID: %d", itemID);
    
    [self.delegate dishOrdered:[self getDishWithID: itemID]];
    [BigSpoonAnimationController animateButtonWhenClicked:(UIView*)sender];
}

-(IBAction)dishCategoryButtonPressed:(UIButton*)button{
    [self.tableView setContentOffset:CGPointZero  animated:NO];
    UIColor *buttonElementColour = [UIColor colorWithRed:CATEGORY_BUTTON_COLOR_RED
                                                   green:CATEGORY_BUTTON_COLOR_GREEN
                                                    blue:CATEGORY_BUTTON_COLOR_BLUE
                                                   alpha:1];
    
    [button setBackgroundColor:buttonElementColour];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    for (UIButton *newButton in self.categoryButtonsArray) {
        if (newButton.tag != button.tag) {
            [newButton setBackgroundColor:[UIColor whiteColor]];
            [newButton setTitleColor:buttonElementColour forState:UIControlStateNormal];
        }
    }
    self.displayCategoryID = button.tag;
    [self moveCurrentCategoryButtonToCenter];
    [self.tableView reloadData];
}

#pragma mark - Others

- (void) moveCurrentCategoryButtonToCenter{
    float offset = [self getOffsetForCenteringCategoryButton];
    if (offset > 0) {
        [self.categoryButtonsHolderView setContentOffset:CGPointMake(offset, 0) animated:YES];
    }
}

- (float) getOffsetForCenteringCategoryButton{
    // rule: content size on both left and right should be >= 160
    // if legal return offset, else return 0
    float sumOfButtonWidthOnTheLeft = 0;
    float sumOfButtonWidthOnTheRight = 0;
    float currentButtonWidth = 0;
    for(int i = 0, len = self.categoryButtonsArray.count; i < len; i++ ){
        if ( i < self.displayCategoryID - 1 ) {
            sumOfButtonWidthOnTheLeft += ((UIButton *)[self.categoryButtonsArray objectAtIndex:i]).frame.size.width;
        } else if (i > self.displayCategoryID - 1) {
            sumOfButtonWidthOnTheRight += ((UIButton *)[self.categoryButtonsArray objectAtIndex:i]).frame.size.width;
        } else {
            currentButtonWidth = ((UIButton *)[self.categoryButtonsArray objectAtIndex:i]).frame.size.width;
        }
    }
    
    if (sumOfButtonWidthOnTheLeft + currentButtonWidth/2 >= 160 && sumOfButtonWidthOnTheRight + currentButtonWidth/2 >= 160) {
        return sumOfButtonWidthOnTheLeft - 160 + currentButtonWidth/2;
    } else {
        return 0;
    }
}

- (Dish *) getDishWithID: (int) itemID{
    for (Dish * dish in self.dishesArray) {
        if (dish.ID == itemID) {
            return dish;
        }
    }
    NSLog(@"Dish with itemID: %d, was not found when trying to order", itemID);
    return nil;
}

- (NSArray *) getDishWithCategory: (int) categoryID{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (Dish *dish in self.dishesArray) {
        for (NSNumber *number in dish.categories) {
            if ([number integerValue] == categoryID) {
                [result addObject:dish];
                break;
            }
        }
    }
    
    // sort according to pos number
    NSArray *sortedArray = [result sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int first = [(Dish*)a pos];
        int second = [(Dish*)b pos];
        return first >= second;
    }];
    
    return sortedArray;
}


@end
