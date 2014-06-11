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
    UIActivityIndicatorView *indicator;
}
@property NSMutableDictionary* dishesByCategory;
@property Dish *chosenDish;
@end

@implementation MenuTableViewController
@synthesize dishesByCategory;
@synthesize jsonForDishesTablesAndCategories;

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
    self.displayCategoryID = -1;
    self.categoryButtonsArray = [[NSMutableArray alloc] init];
    self.dishesByCategory = [[NSMutableDictionary alloc] init];
    // By default:
    self.displayMethod = kMethodPhoto;
    [self initActivityIndicator];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDish) name:NOTIF_ORDER_UPDATE object:nil];
    if(self.jsonForDishesTablesAndCategories){
        [self handleJsonWithDishesAndTableInfos: self.jsonForDishesTablesAndCategories];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDishAndCateLoading:) name:NOTIF_NEW_DISH_INFO_RETRIEVED object:nil];
        [[User sharedInstance] loadDishesAndTableInfosFromServerForOutlet: self.outlet.outletID];
        [self showLoadingIndicators];
    }
}

- (void) handleDishAndCateLoading: (NSNotification*) notif{
    [self stopLoadingIndicators];
    self.jsonForDishesTablesAndCategories = (NSDictionary* )[notif object];
    [self handleJsonWithDishesAndTableInfos: self.jsonForDishesTablesAndCategories];
}

- (void) viewDidAppear:(BOOL)animated{
    if ([User sharedInstance].updatePending) {
        [self updateDish];
        [User sharedInstance].updatePending = NO;
    }
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
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
        if (dish.price < 0.01){
            cell.addButton.hidden = YES;
            cell.priceLabel.hidden = YES;
            [cell.nameLabel setFont:[UIFont italicSystemFontOfSize:13]];
        } else {
            cell.addButton.hidden = NO;
            cell.priceLabel.hidden = NO;
            [cell.nameLabel setFont:[UIFont boldSystemFontOfSize:14]];
        }
        return cell;

    }
    
    else {
        
        MenuPhotoCell *cell = (MenuPhotoCell *)[tableView
                                              dequeueReusableCellWithIdentifier:@"MenuPhotoCell"];
        if(dish.quantity == 0){
            [cell.overlayImageView setImage:[UIImage imageNamed:DISH_OVERLAY_OUT_OF_STOCK]];
        } else {
            [cell.overlayImageView setImage:[UIImage imageNamed:DISH_OVERLAY_NORMAL]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // When the button is clicked, we know which one. :)
        cell.addButton.tag = dish.ID;

        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imageView setClipsToBounds:YES];
        cell.imageView.autoresizingMask = UIViewAutoresizingNone;
        // !! placeholderImage CANNOT be nil
        [cell.imageView setImageWithContentsOfURL:dish.imgURL placeholderImage:[UIImage imageNamed:@"white315_203.gif"]];
        
       // CGRect frame = cell.imageView.frame;
       // frame.origin.x = 0;
       // frame.origin.y = 0;
       // cell.imageView.frame = frame;
        
        cell.ratingImageView.image = nil;//[self imageForRating:dish.ratings];
        
        cell.nameLabel.text = dish.name;
        [cell.nameLabel alignBottom];
        
        
        cell.priceLabel.text = [NSString stringWithFormat:@"%.1f", dish.price];
        
        cell.descriptionLabel.text = dish.description;
        [cell.descriptionLabel alignTop];
        if (dish.price < 0.01){
            cell.addButton.hidden = YES;
            cell.priceLabel.hidden = YES;
        } else {
            cell.addButton.hidden = NO;
            cell.priceLabel.hidden = NO;
        }
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


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"SegueToAddDishModifier"]) {
         DishModifierTableViewController *modifierPopup = segue.destinationViewController;
         modifierPopup.targetingDish = self.chosenDish;
         modifierPopup.delegate = self;
         UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target: nil action: nil];
         [[self navigationItem] setBackBarButtonItem: newBackButton];
         
     } else{
         NSLog(@"Segureee in the outletsViewController cannot assign delegate to its segue. Segue identifier: %@", segue.identifier);
     }
 }

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

#pragma mark - Table view Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.displayMethod == kMethodList){
        [self.delegate displayModeDidChange];
        [self.tableView setContentOffset:CGPointMake(0, indexPath.row * ROW_HEIGHT_PHOTO_MENU)  animated:NO];
    }
}

#pragma mark - Loading Data:

- (NSMutableArray *)parseFromJsonsToDishes:(NSDictionary *)json {
    NSArray *dishes = (NSArray *)[json objectForKey:@"dishes"];
    NSMutableArray *resultingDishes = [[NSMutableArray alloc] init];
    NSMutableDictionary *allCategoriesForCurrentOutlet = [[NSMutableDictionary alloc] init];
    self.dishCategoryArray = [[NSMutableArray alloc] init];
    for (NSDictionary *newDish in dishes) {
        NSError *error;
        NSDictionary *customOrderInfoDic;
        DishModifier *modifier;
        BOOL canBeCustomized = [[newDish objectForKey:@"can_be_customized"] boolValue];
        if (canBeCustomized){
            customOrderInfoDic = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:[[newDish objectForKey:@"custom_order_json"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            modifier = [[DishModifier alloc] initWithJsonDictionary:customOrderInfoDic];
        }
        
        NSDictionary *photo = (NSDictionary *)[newDish objectForKey:@"photo"];
        NSString *thumbnail = (NSString *)[photo objectForKey:@"thumbnail_large"]; //original,thumbnail_large,thumbnail
        if (thumbnail == nil || thumbnail.length == 0){
            thumbnail = [NSString stringWithFormat:@"media/%@", self.outlet.defaultDishPhoto ];
        }
        NSURL *imgURL = [[NSURL alloc] initWithString:[BASE_URL stringByAppendingString:thumbnail]];
        
        NSArray *categories = (NSArray *)[newDish objectForKey:@"categories"];
        NSMutableArray *categoryIDs = [[NSMutableArray alloc]init];
        
        for (NSDictionary *newCategory in categories) {
            int integerValue = [[newCategory objectForKey:@"id"] intValue];
            [categoryIDs addObject: [[NSNumber alloc] initWithInt: integerValue]];
        }
        
        if( [categories count] > 0 && [[[categories objectAtIndex:0] allKeys] count] == 3 && ![[allCategoriesForCurrentOutlet allKeys] containsObject: [[categories objectAtIndex:0] objectForKey:@"name"]]) {
            NSDictionary *newCategory = [categories objectAtIndex:0];
            [allCategoriesForCurrentOutlet setObject:newCategory forKey: [newCategory objectForKey:@"name"]];
            NSNumber *categoryID = (NSNumber *)[newCategory objectForKey:@"id"];
            NSString *name = [newCategory objectForKey:@"name"];
            NSString *description = [newCategory objectForKey:@"desc"];
            
            DishCategory *newObj = [[DishCategory alloc] initWithID:[categoryID integerValue]
                                                               name:name
                                                     andDescription:description];
            [self.dishCategoryArray addObject:newObj];
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
                                        canBeCustomized:canBeCustomized
                                        customOrderInfo:modifier
                               
                               ];
        if ([categories count] > 0) {
            [resultingDishes insertObject:newDishObject atIndex:0];
        } else{
            [resultingDishes addObject:newDishObject];
        }
    }
    self.dishCategoryArray = [[self.dishCategoryArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int first = [(DishCategory*)a ID];
        int second = [(DishCategory*)b ID];
        return first >= second;
    }] mutableCopy];
    return resultingDishes;
}

- (NSMutableDictionary *)parseFromJsonToValidTableIDs:(NSDictionary *)json {
    // Retrieve valid table IDs:
    NSMutableDictionary *validTableIDs = [[NSMutableDictionary alloc] init];
    NSArray *tables = (NSArray *)[json objectForKey:@"tables"];
    for (NSDictionary *newTable in tables) {
        NSNumber *tableID = (NSNumber *)[newTable objectForKey: @"id" ];
        NSString *tableCode = [[newTable objectForKey: @"code"] lowercaseString];
        [validTableIDs setObject:tableID  forKey:tableCode];
    }
    return validTableIDs;
}

- (void)handleJsonWithDishesAndTableInfos: (NSDictionary *)json{
    self.dishesArray = [self parseFromJsonsToDishes:json];
    [self renderCategoryButtons];
    [self.tableView reloadData];
    
    NSMutableDictionary *validTableIDs = [self parseFromJsonToValidTableIDs:json];
    [self.delegate setValidTableIDs:validTableIDs];
}

- (void)renderCategoryButtons {
    int sumOfCategoryButtonWidths = 0;
    int buttonHeight = self.categoryButtonsHolderView.frame.size.height - CATEGORY_BUTTON_OFFSET;
    UIColor *buttonElementColour = [UIColor colorWithRed:CATEGORY_BUTTON_COLOR_RED
                                                   green:CATEGORY_BUTTON_COLOR_GREEN
                                                    blue:CATEGORY_BUTTON_COLOR_BLUE
                                                   alpha:1];
    
    for (DishCategory *newCategory in self.dishCategoryArray) {
        // Add one more category button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = (NSInteger) newCategory.ID;
        button.layer.borderColor = buttonElementColour.CGColor;
        button.layer.borderWidth = CATEGORY_BUTTON_BORDER_WIDTH;
        
        [button setTitleColor:buttonElementColour forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"YanaR-Bold" size: CATEGORY_BUTTON_FONT];
        
        [button addTarget:self
                   action:@selector(dishCategoryButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        
        // Add spaces before and after the title:
        NSString *buttonTitle = [newCategory.name stringByAppendingString:@"  "];
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

#pragma mark Time parsing Methods

- (NSDate *)dateByNeutralizingDateComponentsOfDate:(NSDate *)originalDate {
    NSCalendar *gregorian = [[NSCalendar alloc]
                              initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Get the components for this date
    NSDateComponents *components = [gregorian components:  (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate: originalDate];
    
    // Set the year, month and day to some values (the values are arbitrary)
    [components setYear:2000];
    [components setMonth:1];
    [components setDay:1];
    
    return [gregorian dateFromComponents:components];
}

/*
 *  @param: timeString, a string of format @"HH:mm:ss"
 *  @return: NSDate with neutralized year, month and day.
 *
 */
- (NSDate *)neutrilizedDateFromTimeString: (NSString*) timeString{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_SG"]];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate* date = [dateFormatter dateFromString:timeString];
    
    if (!timeString) {
        return nil;
    }
    
    // Make sure all the dates have the same date component.
    NSDate *newDate = [self dateByNeutralizingDateComponentsOfDate:date];
    
    return newDate;
}

- (BOOL)isCurrentTimeBetweenStartDate:(NSString* )startDate andEndDate:(NSString *)endDate {
    
    NSDate *newStartDate = [self neutrilizedDateFromTimeString:startDate];
    NSDate *newEndDate = [self neutrilizedDateFromTimeString:endDate];
    NSDate *newTargetDate = [self dateByNeutralizingDateComponentsOfDate:[NSDate date]];
    
    if (newStartDate == nil || newEndDate == nil) {
        return NO;
    }
    
    // Compare the target with the start and end dates
    NSComparisonResult compareTargetToStart = [newTargetDate compare:newStartDate];
    NSComparisonResult compareTargetToEnd = [newTargetDate compare:newEndDate];
    
    return (compareTargetToStart == NSOrderedDescending && compareTargetToEnd == NSOrderedAscending);
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

- (IBAction)addNewItemButtonClicked:(id)sender {
    [BigSpoonAnimationController animateButtonWhenClicked:(UIView*)sender];
    UIButton *btn = (UIButton *)sender;
    int itemID = btn.tag;
    Dish* clickedDish = [self getDishWithID: itemID];
    
    if ([self isCurrentTimeBetweenStartDate:clickedDish.startTime andEndDate: clickedDish.endTime] && clickedDish.quantity > 0){
        if(clickedDish.canBeCustomized){
            self.chosenDish = clickedDish;
            [self performSegueWithIdentifier:@"SegueToAddDishModifier" sender:self];
        } else {
            [self.delegate dishOrdered:clickedDish];
        }
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat: @"addNewItem button for %@ pressed.-> Legal", clickedDish.name]];
        if (self.displayMethod == kMethodList){
            [[Mixpanel sharedInstance] track:@"Added item in list menu"];
        } else {
            [[Mixpanel sharedInstance] track:@"Added item in picture menu"];
        }
    } else if (clickedDish.quantity <= 0){
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat: @"addNewItem button for %@ pressed. -> Out of stock", clickedDish.name]];
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message: @"This is out of stock :("
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat: @"addNewItem button for %@ pressed. -> Wrong time", clickedDish.name]];
        NSDate* startDate = [self neutrilizedDateFromTimeString:clickedDish.startTime];
        NSDate* endDate = [self neutrilizedDateFromTimeString:clickedDish.endTime];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm"];
        dateFormatter.timeStyle = kCFDateFormatterShortStyle;
        
        NSString* startDateString = [dateFormatter stringFromDate:startDate];
        NSString* endDateString = [dateFormatter stringFromDate:endDate];
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message: [NSString stringWithFormat:@"This dish is only available from\n%@ to %@",                    startDateString, endDateString]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
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
    self.displayCategoryPosition = [self getPositionForCategoryWithId: button.tag];
    [self moveCurrentCategoryButtonToCenter];
    [self.tableView reloadData];
}

#pragma mark - Others

- (void) moveCurrentCategoryButtonToCenter{
    float offset = [self getOffsetForCenteringCategoryButton];
    [self.categoryButtonsHolderView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

- (float) getOffsetForCenteringCategoryButton{
    // rule: content size on both left and right should be >= 160
    // if legal return offset, else return 0
    float sumOfButtonWidthOnTheLeft = 0;
    float sumOfButtonWidthOnTheRight = 0;
    float currentButtonWidth = 0;
    for(int i = 0, len = self.categoryButtonsArray.count; i < len; i++ ){
        if ( i < self.displayCategoryPosition) {
            sumOfButtonWidthOnTheLeft += ((UIButton *)[self.categoryButtonsArray objectAtIndex:i]).frame.size.width;
        } else if (i > self.displayCategoryPosition) {
            sumOfButtonWidthOnTheRight += ((UIButton *)[self.categoryButtonsArray objectAtIndex:i]).frame.size.width;
        } else {
            currentButtonWidth = ((UIButton *)[self.categoryButtonsArray objectAtIndex:i]).frame.size.width;
        }
    }
    
    if (sumOfButtonWidthOnTheLeft + currentButtonWidth/2 >= 160 && sumOfButtonWidthOnTheRight + currentButtonWidth/2 >= 160) {
        return sumOfButtonWidthOnTheLeft - 160 + currentButtonWidth/2;
    } else if (sumOfButtonWidthOnTheLeft + currentButtonWidth/2 < 160){
        return 0;
    } else {
        return self.categoryButtonsHolderView.contentSize.width - 320;
    }
}

- (void) updateDish {
    for(int i = 0 ; i < [[User sharedInstance].pastOrder.dishes count] ; i++){
        Dish *currentDish = [[User sharedInstance].pastOrder.dishes objectAtIndex: i];
        [[User sharedInstance].pastOrder.dishes replaceObjectAtIndex:i withObject:[self getDishWithID:currentDish.ID]];
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
    NSString* keyForCat = [NSString stringWithFormat:@"%d", categoryID];
    if ([self.dishesByCategory objectForKey:keyForCat] != nil){
        return (NSArray *)[self.dishesByCategory objectForKey:keyForCat];
    }
    
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
    if ( [sortedArray count] > 0){
        [self.dishesByCategory setObject:sortedArray forKey:keyForCat];
    }
    
    return sortedArray;
}

- (int) getPositionForCategoryWithId: (int)categoryId{
    for(int i = 0 ; i< [self.dishCategoryArray count]; i ++){
        if (((DishCategory*)[self.dishCategoryArray objectAtIndex:i]).ID == categoryId){
            return i;
        }
    }
    return 0;
}

#pragma mark - DishModifierSegueDelegate

- (void) dishModifierPopupDidSaveWithUpdatedModifier:(Dish *)newDishWithModifier {
    [self.delegate dishOrdered:newDishWithModifier];
}

- (void) dishModifierPopupDidCancel{
    
}

#pragma mark Show and hide indicators
- (void)initActivityIndicator
{
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

- (void) showLoadingIndicators{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
    [self.tableView setUserInteractionEnabled:NO];
}

- (void) stopLoadingIndicators{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [indicator stopAnimating];
    [self.tableView setUserInteractionEnabled:YES];
}


@end
