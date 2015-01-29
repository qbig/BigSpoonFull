//
//  CategoryTableViewController.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/1/15.
//  Copyright (c) 2015 nus.cs3217. All rights reserved.
//

#import "CategoriesTableViewController.h"
#import "MenuViewController.h"
@interface CategoriesTableViewController ()

@end

@implementation CategoriesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userInfo = [User sharedInstance];
    [self.navigationItem setTitle: [self.outlet.name eclipsizeWithLengthLimit:MAX_NUM_OF_CHARS_IN_NAVIGATION_ITEM]];
    @try {
        self.dishesArray = [self parseFromJsonsToDishes:self.jsonForDishesTablesAndCategories];
    }
    @catch (NSException *exception) {
        CLS_LOG(@"handleJsonWithDishesAndTableInfos issue: %@", exception);
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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
        NSString *thumbnail = (NSString *)[photo objectForKey:@"original"]; //original,thumbnail_large,thumbnail
        if (thumbnail == nil || thumbnail.length == 0 || [thumbnail rangeOfString:@"default.jpg"].location != NSNotFound ){
            if(self.outlet.defaultDishPhoto != nil) {
                thumbnail = [[NSString stringWithFormat:@"media/%@", self.outlet.defaultDishPhoto] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            } else {
                thumbnail = BG_DEFAULT_DISH_PHOTO_URL;
            }
            
        }
        
        NSURL *imgURL = [[NSURL alloc] initWithString:[BASE_URL stringByAppendingString:thumbnail]];
        NSArray *categories = (NSArray *)[newDish objectForKey:@"categories"];
        NSMutableArray *categoryIDs = [[NSMutableArray alloc]init];
        
        for (NSDictionary *newCategory in categories) {
            int integerValue = [[newCategory objectForKey:@"id"] intValue];
            [categoryIDs addObject: [[NSNumber alloc] initWithInt: integerValue]];
        }
        
        if( [categories count] > 0 && [[[categories objectAtIndex:0] allKeys] count] >= 3 && ![[allCategoriesForCurrentOutlet allKeys] containsObject: [[categories objectAtIndex:0] objectForKey:@"name"]]) {
            NSDictionary *newCategory = [categories objectAtIndex:0];
            [allCategoriesForCurrentOutlet setObject:newCategory forKey: [newCategory objectForKey:@"name"]];
            NSNumber *categoryID = (NSNumber *)[newCategory objectForKey:@"id"];
            NSString *name = [newCategory objectForKey:@"name"];
            NSString *description = [newCategory objectForKey:@"desc"];
            BOOL isListOnly = [[newCategory objectForKey:@"is_list_view_only"] boolValue];
            DishCategory *newCatObj = [[DishCategory alloc] initWithID:[categoryID integerValue]
                                                                  name:name
                                                        andDescription:description isListOnly:isListOnly];
            [self.dishCategoryArray addObject:newCatObj];
        }
        
        
        int ID = [[newDish objectForKey:@"id"] intValue];
        NSString* name = [newDish objectForKey:@"name"];
        int pos = [[newDish objectForKey:@"pos"] intValue];
        int index = [[newDish objectForKey:@"position_index"] intValue];
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
                                                  index:index
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
    
    NSArray *categorySequences = (NSArray *)[json objectForKey:@"categories_order"];
    for( NSDictionary *sequence in categorySequences){
        int categoryId = [[sequence objectForKey:@"category_id"] intValue];
        int index = [[sequence objectForKey:@"order_index"] intValue];
        for(DishCategory *cat in self.dishCategoryArray){
            if (cat.ID == categoryId){
                cat.orderIndex = index;
            }
        }
    }
    
    
    self.dishCategoryArray = [[self.dishCategoryArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int first = [(DishCategory*)a orderIndex];
        int second = [(DishCategory*)b orderIndex];
        return first >= second;
    }] mutableCopy];
    
    return resultingDishes;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dishCategoryArray count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        CategoriesHeaderCell *cell = (CategoriesHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"CategoriesHeaderCell" forIndexPath:indexPath];
        cell.phoneNumLabel.text = self.outlet.phoneNumber;
        cell.openHoursLabel.text = self.outlet.operatingHours;
        [cell.restaurantIconImageView setImageWithURL:self.outlet.imgURL placeholderImage:[UIImage imageNamed:@"white315_203.gif"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.restaurantIconImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        cell.restaurantIconImageView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        cell.restaurantIconImageView.layer.shadowOpacity = 0.8f;
        cell.restaurantIconImageView.layer.shadowRadius = 2.0f;
        cell.restaurantIconImageView.layer.shadowPath =
        [UIBezierPath bezierPathWithRect:cell.restaurantIconImageView.layer.bounds].CGPath;
        return cell;
    } else {
        CategoriesNormalCell *cell = (CategoriesNormalCell*) [tableView dequeueReusableCellWithIdentifier:@"CategoriesNormalCell" forIndexPath:indexPath];
        DishCategory *category = (DishCategory *) [self.dishCategoryArray objectAtIndex:indexPath.row - 1];
        cell.categoryNameLabel.text = category.name;
        [cell.categoryIconImageView setImageWithURL:[self getCategoryImageURL:category.ID] placeholderImage:[UIImage imageNamed:@"white315_203.gif"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self setFloorFadeShadow:cell.categoryIconImageView];
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0) {
        [self performSegueWithIdentifier:@"SegueFromCategoriesToMenu" sender:nil];
    }
}

- (NSURL*) getCategoryImageURL: (int) categoryID{
    for (Dish * dish in self.dishesArray) {
        for (NSNumber *number in dish.categories) {
            if ([number integerValue] == categoryID) {
                return dish.imgURL;
            }
        }
    }
    return nil;
}

- (void) setFloorFadeShadow: (UIView*) view {
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 1.0f;
    view.layer.shadowRadius = 1.0f;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.layer.bounds].CGPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] == 0) {
        return 140;
    } else {
        return 100;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueFromCategoriesToMenu"]) {
        MenuViewController *menuViewController = segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        DishCategory *category = (DishCategory *) [self.dishCategoryArray objectAtIndex:selectedIndexPath.row - 1];
        menuViewController.selectedCategory = category;
        menuViewController.delegate = self.delegate;
        menuViewController.outlet = self.outlet;
        menuViewController.jsonForDishesTablesAndCategories = self.jsonForDishesTablesAndCategories;
        
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStyleBordered target: nil action: nil];
        [[self navigationItem] setBackBarButtonItem: newBackButton];
        
    }
}

@end
