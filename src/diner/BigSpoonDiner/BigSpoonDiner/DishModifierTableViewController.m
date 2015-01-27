//
//  DishModifierTableViewController.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 28/5/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "DishModifierTableViewController.h"
#import "UIColor+ColorFromHex.h"
@interface DishModifierTableViewController ()
@property bool isNavBarInitiallyHidden;
@end

@implementation DishModifierTableViewController
@synthesize isNavBarInitiallyHidden;

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
    self.isNavBarInitiallyHidden = self.navigationController.navigationBarHidden;
    // Setting  background and text color
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexString: self.targetingDish.customOrderInfo.backgroundColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationItem.titleView setBackgroundColor:[UIColor colorFromHexString: self.targetingDish.customOrderInfo.backgroundColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]};
    self.navigationController.navigationBarHidden = NO;
    
    [self.tableView setBackgroundColor: [UIColor colorFromHexString: self.targetingDish.customOrderInfo.backgroundColor]];
    [self.tableView setBackgroundView: nil];
    
    // Setting "Cancel" and "OK" buttons at the end of the list
    UIButton *cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, 130, 40);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor blackColor];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *okButton = [UIButton buttonWithType: UIButtonTypeCustom];
    okButton.frame = CGRectMake(150, 0, 130, 40);
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor colorFromHexString:@"#8BCC6F"];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    [footerView addSubview:cancelButton];
    [footerView addSubview:okButton];
    self.tableView.tableFooterView = footerView;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = self.isNavBarInitiallyHidden;
    UIColor *bigSpoonBlue = [UIColor colorFromHexString:@"#FF6235"];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = bigSpoonBlue;
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = bigSpoonBlue;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

}

- (void) okButtonPressed {
    [self.delegate dishModifierPopupDidSaveWithUpdatedModifier:self.targetingDish];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancelButtonPressed {
    [self.delegate dishModifierPopupDidCancel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.targetingDish.customOrderInfo.modifierSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    
    // Setting text style and color of Section title
    NSMutableAttributedString *attString;
    if (currentSection.itemTitleDescription.length != 0){
        attString = [[NSMutableAttributedString alloc]
         initWithString: [NSString stringWithFormat:@"%@( %@ )", currentSection.itemTitle, currentSection.itemTitleDescription]];
        [attString addAttribute: NSForegroundColorAttributeName
                          value: [UIColor colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]
                          range: NSMakeRange(currentSection.itemTitle.length, attString.length - currentSection.itemTitle.length)];
        [attString addAttribute: NSFontAttributeName
                          value:  [UIFont fontWithName:@"Helvetica" size:14]
                          range: NSMakeRange(currentSection.itemTitle.length, attString.length - currentSection.itemTitle.length)];

    } else {
        attString = [[NSMutableAttributedString alloc]
                     initWithString: [NSString stringWithFormat:@"%@", currentSection.itemTitle]];
    }
    
    [attString addAttribute: NSForegroundColorAttributeName
                      value: [UIColor colorFromHexString:self.targetingDish.customOrderInfo.itemTitleColor]
                      range: NSMakeRange(0, currentSection.itemTitle.length)];
    
    [attString addAttribute: NSFontAttributeName
                      value:  [UIFont fontWithName:@"Helvetica-Bold" size:16]
                      range: NSMakeRange(0,currentSection.itemTitle.length)];

    cell.textLabel.attributedText = attString;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
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
    
    if ([currentSection.type isEqualToString:DISH_MODIFIER_TYPE_COUNT]){
        DishModifierItemCellCount *cellCount = (DishModifierItemCellCount *) [tableView dequeueReusableCellWithIdentifier:@"cellForModiferItemCount" forIndexPath:indexPath];
        [cellCount.itemNameLabel setTextColor:[UIColor colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]];
        cellCount.itemNameLabel.text = item.itemName;
        cellCount.itemCountLabel.text = [NSString stringWithFormat:@"%d",item.itemCount];
        cellCount.itemNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cellCount.itemNameLabel.numberOfLines = 2;
        cellCount.item = item;
        cell = cellCount;
    } else {
        DishModifierItemCellRadio *cellRadio = (DishModifierItemCellRadio *) [tableView dequeueReusableCellWithIdentifier:@"cellForModiferItemRadio" forIndexPath:indexPath];
        [cellRadio.itemNameLabel setTextColor:[UIColor colorFromHexString:self.targetingDish.customOrderInfo.itemTextColor]];
        cellRadio.itemNameLabel.text = item.itemName;
        cellRadio.itemNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cellRadio.itemNameLabel.numberOfLines = 2;
        cellRadio.item = item;
        cellRadio.selectorColor = [UIColor colorFromHexString:self.targetingDish.customOrderInfo.itemTitleColor];
        [cellRadio render];
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
        DishModifierSection *currentSection = [self.targetingDish.customOrderInfo.modifierSections objectAtIndex:indexPath.section];
        DishModifierItem *item = [currentSection.items objectAtIndex: indexPath.row];
        
        // toggling radio selection
        if (item.itemCount == 0){
            item.itemCount = 1;
            for (DishModifierItem *otherItem in currentSection.items){
                if(![otherItem.itemName isEqualToString:item.itemName]){
                    otherItem.itemCount = 0;
                }
            }
        }

        [self.tableView reloadData];
        return nil;
    }
    return indexPath;
}

@end
