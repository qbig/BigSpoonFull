//
//  DishModifierTableViewController.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DishModifierTableViewController.h"

@interface DishModifierTableViewController ()
{
    NSDictionary *animals;
    NSArray *animalSectionTitles;
    NSArray *animalIndexTitles;
}
@end

@implementation DishModifierTableViewController

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
    
    animals = @{@"B" : @[@"Bear", @"Black Swan", @"Buffalo"],
                @"C" : @[@"Camel", @"Cockatoo"],
                @"D" : @[@"Dog", @"Donkey"],
                @"E" : @[@"Emu"],
                @"G" : @[@"Giraffe", @"Greater Rhea"],
                @"H" : @[@"Hippopotamus", @"Horse"],
                @"K" : @[@"Koala"],
                @"L" : @[@"Lion", @"Llama"],
                @"M" : @[@"Manatus", @"Meerkat"],
                @"P" : @[@"Panda", @"Peacock", @"Pig", @"Platypus", @"Polar Bear"],
                @"R" : @[@"Rhinoceros"],
                @"S" : @[@"Seagull"],
                @"T" : @[@"Tasmania Devil"],
                @"W" : @[@"Whale", @"Whale Shark", @"Wombat"]};
    
    animalSectionTitles = [[animals allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
   
    
    NSMutableAttributedString *attString =
    [[NSMutableAttributedString alloc]
     initWithString: @"header!!!!!!!"];
    
    [attString addAttribute: NSForegroundColorAttributeName
                      value: [UIColor blueColor]
                      range: NSMakeRange(7,4)];
    [attString addAttribute: NSForegroundColorAttributeName
                      value: [UIColor redColor]
                      range: NSMakeRange(0,6)];
    
    [attString addAttribute: NSFontAttributeName
                      value:  [UIFont fontWithName:@"Helvetica" size:15]
                      range: NSMakeRange(0,6)];
    
    [attString addAttribute: NSFontAttributeName
                      value:  [UIFont fontWithName:@"Didot" size:24]
                      range: NSMakeRange(7,4)];

    
    UILabel *labelB = [[UILabel alloc] init];
    labelB.frame = CGRectMake(0, 0, 280, 40);
    labelB.attributedText  = attString;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    [footerView addSubview:labelB];
    self.tableView.tableFooterView = footerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [animalSectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *sectionTitle = [animalSectionTitles objectAtIndex:section];
    NSArray *sectionAnimals = [animals objectForKey:sectionTitle];
    return [sectionAnimals count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [animalSectionTitles objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cellForModifierSectionHeader"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"cellForModifierSectionHeader"];
    }
    
    
    NSMutableAttributedString *attString =
    [[NSMutableAttributedString alloc]
     initWithString: @"monkey goat"];
    
    [attString addAttribute: NSForegroundColorAttributeName
                      value: [UIColor blueColor]
                      range: NSMakeRange(7,4)];
    [attString addAttribute: NSForegroundColorAttributeName
                      value: [UIColor redColor]
                      range: NSMakeRange(0,6)];
    
    [attString addAttribute: NSFontAttributeName
                      value:  [UIFont fontWithName:@"Helvetica" size:15]
                      range: NSMakeRange(0,6)];
    
    [attString addAttribute: NSFontAttributeName
                      value:  [UIFont fontWithName:@"Didot" size:24]
                      range: NSMakeRange(7,4)];
    
    cell.textLabel.attributedText = attString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellForModiferItem" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *sectionTitle = [animalSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionAnimals = [animals objectForKey:sectionTitle];
    NSString *animal = [sectionAnimals objectAtIndex:indexPath.row];
    //    cell.textLabel.text = animal;
    //  cell.imageView.image = [UIImage imageNamed:[self getImageFilename:animal]];
    
    return cell;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//  //  return animalSectionTitles;
//    return animalIndexTitles;
//}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [animalSectionTitles indexOfObject:title];
}

@end
