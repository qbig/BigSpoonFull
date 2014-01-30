//
//  RatingAndFeedbackViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 13/11/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RatingAndFeedbackViewController.h"

@interface RatingAndFeedbackViewController ()

@end

@implementation RatingAndFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    
    self.ratings = [[NSMutableDictionary alloc] init];
}

- (void) viewDidLoad{
    [super viewDidLoad];
    
    // Initial default value:
    self.initialY = -1000;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Show success message of the request of bill
    [self.view makeToast:@"The waiter will be right with you."
                duration:TOAST_VIEW_DURATION
                position:@"center"
                   title:@"Request for bill is submitted"];
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
    return [self.orderToRate getNumberOfKindsOfDishes];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RatingCell *cell = (RatingCell *)[tableView
                                      dequeueReusableCellWithIdentifier:@"RatingCell"];
    
    //RatingCell *cell = [[RatingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RatingCell"];

    Dish *dish = [[self.orderToRate dishes] objectAtIndex:indexPath.row];
    
    cell.dishNameLabel.text = dish.name;
    
    // By default, show five stars.
    cell.ratingImage.image = [self imageForRating:5];
    
    // Tag it. So that we know its identity.
    cell.tag = dish.ID;
    NSLog(@"Tagged: %d", dish.ID);
    
    // Add gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tappedRatingImageView:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    [cell.ratingImage setUserInteractionEnabled:YES];
    [cell.ratingImage addGestureRecognizer:tapRecognizer];
    
    return cell;
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

-(void)tappedRatingImageView: (UITapGestureRecognizer *)gesture{

    CGPoint location = [gesture locationInView: self.ratingsTableView];
    NSIndexPath * indexPath = [self.ratingsTableView indexPathForRowAtPoint: location];
    RatingCell *cell = (RatingCell *)[self.ratingsTableView cellForRowAtIndexPath: indexPath];

    int dishID = cell.tag;

    location = [gesture locationInView: cell.ratingImage];
    int newRating = ((int) location.x) / (RATING_STAR_WIDTH / NUM_OF_RATINGS) + 1;

    cell.ratingImage.image = [self imageForRating:newRating];
    [self setRating:newRating ofDishID:dishID];
    [TestFlight passCheckpoint:@"CheckPoint:User set rating stars"];
}

- (void) setRating: (int) newRating ofDishID: (int) dishID{
    NSLog(@"New rating: %d for dish: %d", newRating, dishID);

    [self.ratings setObject:[NSString stringWithFormat:@"%d", newRating] forKey:[NSString stringWithFormat:@"%d", dishID]];
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

# pragma mark - Event listeners

- (IBAction)ratingSubmitButtonPressed:(id)sender{
    // Perfrom HTTP Call:
    
    [self performRatingSubmission];
    [self performFeedbackSubmission];
    
    [self ratingCancelButtonPressed:sender];
    [TestFlight passCheckpoint:@"CheckPoint:User Submitting rating"];
}

- (void) performRatingSubmission{
    
    NSMutableArray *ratingsArray = [[NSMutableArray alloc] init];
    
    for (NSString *key in [self.ratings allKeys]) {
        NSDictionary *pair = [NSDictionary dictionaryWithObject:[self.ratings objectForKey:key] forKey:key];
        [ratingsArray addObject:pair];
    }
    
    NSDictionary *parameters = @{
      @"dishes": ratingsArray
    };
    
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: RATING_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted error:&error];

    
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        int responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{
                NSLog(@"Submit Rating Success");
                [self displaySuccessInfoAfterSubmittingRating];
            }
                break;
            case 403:
            default:{
                NSLog(@"Submit Rating Fail");
            }
        }
        NSLog(@"Response: %@", responseObject);
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          // TODO
                                          // For some weird reason, even if it's successful, it still come to this
                                          // block. So we check the response code. If it's 200, it's successful.
                                          // This might be a backend error, though.
                                          if ([operation.response statusCode] != 200){
                                              [self displayErrorInfo: operation.responseObject];
                                          } else{
                                              NSLog(@"Submit Rating Success, but in failure block.");
                                              [self displaySuccessInfoAfterSubmittingRating];
                                          }
                                      }];
    
    [operation start];
}

- (void) displaySuccessInfoAfterSubmittingRating{
    [self.delegate ratingAndFeedbackDidSubmitted];
}

- (void) performFeedbackSubmission{
    NSString *feedback = self.feedbackTextField.text;
    
    if ([feedback length] == 0) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"outlet": [NSNumber numberWithInt: self.outletID],
                                 @"feedback": feedback
                                 };
    
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: FEEDBACK_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.authToken] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        int responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{
                NSLog(@"Submit Feedback Success");
                
            }
                break;
            case 403:
            default:{
                NSLog(@"Submit Feedback Fail");
            }
        }
        NSLog(@"Response: %@", responseObject);
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Submit Feedback failed with code: %d", [operation.response statusCode]
                                                );
                                    }];
    
    [operation start];
}

- (void) displayErrorInfo: (id) responseObject{
    
    NSDictionary *dictionary = (NSDictionary *)responseObject;
    
    NSMutableString *message = [[NSMutableString alloc] init];
    
    NSArray *errorInfoArray= [dictionary allValues];
    
    for (NSString * errorInfo in errorInfoArray) {
        [message appendString:errorInfo];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Oops"
                              message: message
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}


- (IBAction)ratingCancelButtonPressed:(id)sender{
    
    [self.delegate modalSegueDidExit];
    [TestFlight passCheckpoint:@"CheckPoint:User Cancelled Rating popup"];
}


- (IBAction)textFieldDidBeginEditing:(id)sender {
    
    // If the initialY is not initialized (and hence with a value of -1000, set in viewDIdLoad)
    if (self.initialY == -1000) {
        self.initialY = self.view.frame.origin.y;
    }
    
    if ([sender isEqual:self.feedbackTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= self.initialY)
        {
            [self setViewMovedUp:YES];
        }
    }
}

- (IBAction)textFinishEditing:(id)sender {
    
    [sender resignFirstResponder];
    
    NSLog(@"Did finish editing %f %f", self.view.frame.origin.y, self.initialY);
    
    if ([sender isEqual:self.feedbackTextField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y < self.initialY)
        {
            [self setViewMovedUp:NO];
        }
    }
}

- (void) removeSelfFromParent{
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void) reloadDataWithOrder: (Order *) c andOutletID:(int) o{
    self.outletID = o;
    self.orderToRate = c;
    [self.ratingsTableView reloadData];
    self.ratings = [[NSMutableDictionary alloc] init];
    for (Dish *dish in c.dishes) {
        [self setRating:5 ofDishID:dish.ID];
    }
}

@end
