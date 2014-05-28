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
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = self.targetingDish.name;
    [self.tableView setBackgroundColor: [self colorFromHexString: self.targetingDish.customOrderInfo.backgroundColor]];
    [self.tableView setBackgroundView: nil];
    animals = @{@"B" : @[@"Bear", @"Black Swan", @"Buffalo"],
                @"C" : @[@"Camel", @"Cockatoo"],
                };
    
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
    //==========================================
    
    UIButton *cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(135, 0, 130, 40);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor blackColor];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *okButton = [UIButton buttonWithType: UIButtonTypeCustom];
    okButton.frame = CGRectMake(0, 0, 130, 40);
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    okButton.backgroundColor = [self colorFromHexString:@"#8BCC6F"];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    [footerView addSubview:cancelButton];
    [footerView addSubview:okButton];
    self.tableView.tableFooterView = footerView;
}

- (void) okButtonPressed {
    [self.delegate dishModifierPopupDidSaveWithUpdatedModifier:self.targetingDish.customOrderInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancelButtonPressed {
    [self.delegate dishModifierPopupDidCancel];
    [self.navigationController popViewControllerAnimated:YES];
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
    return [self.targetingDish.customOrderInfo.modifierSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [((DishModifierSection *)[self.targetingDish.customOrderInfo.modifierSections objectAtIndex:section]).items count];
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
    
    DishModifierSection *currentSection = [self.targetingDish.customOrderInfo.modifierSections objectAtIndex:section];
    
    NSMutableAttributedString *attString;
    if (currentSection.itemTitleDescription.length != 0){
        attString = [[NSMutableAttributedString alloc]
         initWithString: [NSString stringWithFormat:@"%@( %@ )", currentSection.itemTitle, currentSection.itemTitleDescription]];
        [attString addAttribute: NSForegroundColorAttributeName
                          value: [self colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]
                          range: NSMakeRange(currentSection.itemTitle.length, attString.length - currentSection.itemTitle.length)];
        [attString addAttribute: NSFontAttributeName
                          value:  [UIFont fontWithName:@"Helvetica" size:10]
                          range: NSMakeRange(currentSection.itemTitle.length, attString.length - currentSection.itemTitle.length)];

    } else {
        attString = [[NSMutableAttributedString alloc]
                     initWithString: [NSString stringWithFormat:@"%@", currentSection.itemTitle]];
    }
    
    [attString addAttribute: NSForegroundColorAttributeName
                      value: [self colorFromHexString:self.targetingDish.customOrderInfo.itemTitleColor]
                      range: NSMakeRange(0, currentSection.itemTitle.length)];
    
    [attString addAttribute: NSFontAttributeName
                      value:  [UIFont fontWithName:@"Helvetica" size:20]
                      range: NSMakeRange(0,currentSection.itemTitle.length - 1)];

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
//    NSString *sectionTitle = [animalSectionTitles objectAtIndex:indexPath.section];
//    NSArray *sectionAnimals = [animals objectForKey:sectionTitle];
//    NSString *animal = [sectionAnimals objectAtIndex:indexPath.row];

    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    cell.selectedBackgroundView = [UIView new];
    
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

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
