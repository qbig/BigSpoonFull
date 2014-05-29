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
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString: self.targetingDish.customOrderInfo.backgroundColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationItem.titleView setBackgroundColor:[self colorFromHexString: self.targetingDish.customOrderInfo.backgroundColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [self colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]};
    
    [self.tableView setBackgroundColor: [self colorFromHexString: self.targetingDish.customOrderInfo.backgroundColor]];
    [self.tableView setBackgroundView: nil];
    animals = @{@"B" : @[@"Bear", @"Black Swan", @"Buffalo"],
                @"C" : @[@"Camel", @"Cockatoo"],
                };
    
    animalSectionTitles = [[animals allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    // Setting "Cancel" and "OK" buttons at the end of the list
    UIButton *cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(150, 0, 130, 40);
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
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancelButtonPressed {
    [self.delegate dishModifierPopupDidCancel];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [self.navigationController popViewControllerAnimated:YES];
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
    return [self.targetingDish.customOrderInfo.modifierSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [((DishModifierSection *)[self.targetingDish.customOrderInfo.modifierSections objectAtIndex:section]).items count];
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
                          value:  [UIFont fontWithName:@"Helvetica" size:14]
                          range: NSMakeRange(currentSection.itemTitle.length, attString.length - currentSection.itemTitle.length)];

    } else {
        attString = [[NSMutableAttributedString alloc]
                     initWithString: [NSString stringWithFormat:@"%@", currentSection.itemTitle]];
    }
    
    [attString addAttribute: NSForegroundColorAttributeName
                      value: [self colorFromHexString:self.targetingDish.customOrderInfo.itemTitleColor]
                      range: NSMakeRange(0, currentSection.itemTitle.length)];
    
    [attString addAttribute: NSFontAttributeName
                      value:  [UIFont fontWithName:@"Helvetica-Bold" size:16]
                      range: NSMakeRange(0,currentSection.itemTitle.length)];

    cell.textLabel.attributedText = attString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DishModifierSection *currentSection = [self.targetingDish.customOrderInfo.modifierSections objectAtIndex:indexPath.section];
    DishModifierItem *item = [currentSection.items objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    DishModifierItemCellCount *cellCount;
    DishModifierItemCellRadio *cellRadio;
    if ([currentSection.type isEqualToString:DISH_MODIFIER_TYPE_COUNT]){
        cellCount = (DishModifierItemCellCount *) [tableView dequeueReusableCellWithIdentifier:@"cellForModiferItemCount" forIndexPath:indexPath];
        [cellCount.itemNameLabel setTextColor:[self colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]];
        cellCount.itemNameLabel.text = item.itemName;
        cellCount.itemCountLabel.text = [NSString stringWithFormat:@"%d",item.itemCount];
        cellCount.item = item;
        cell = cellCount;
    } else {
        cellRadio = (DishModifierItemCellRadio *) [tableView dequeueReusableCellWithIdentifier:@"cellForModiferItemRadio" forIndexPath:indexPath];
        [cellRadio.itemNameLabel setTextColor:[self colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]];
        cellRadio.itemNameLabel.text = item.itemName;
        cellRadio.item = item;
        cell = cellRadio;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    cell.selectedBackgroundView = [UIView new];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
        DishModifierItemCellRadio *cellRadio = (DishModifierItemCellRadio *) cell;
        DishModifierSection *currentSection = [self.targetingDish.customOrderInfo.modifierSections objectAtIndex:indexPath.section];
        DishModifierItem *item = [currentSection.items objectAtIndex: indexPath.row];
        [cellRadio.itemNameLabel setTextColor:[self colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]];
        cellRadio.itemNameLabel.text = item.itemName;
        cellRadio.item = item;
        cellRadio.selectorColor = [self colorFromHexString:self.targetingDish.customOrderInfo.itemTitleColor];
        [cellRadio toggle];
        [cellRadio tapTransition];
        return nil;
    }
    return indexPath;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
