//
//  ProfileViewController.m
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 27/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property NSString* isVegetarian;

- (void) loadUserDetails;
- (void) updateUserDetailsOnServer;
- (void) setStateOfVegetarianButton:(NSString*)isVegetarianValueFromServer;
@end

@implementation ProfileViewController

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
	// Do any additional setup after loading the view.
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"HomeAndSettingsButtonView" owner:self options:nil];
    self.topRightButtonsView = [subviewArray objectAtIndex:0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.topRightButtonsView];
    self.profilePictureView.image = [User sharedInstance].profileImage;
    [self loadUserDetails];
}

- (void) updateUserDetailsOnServer {
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: PROFILE_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.auth_token] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSLog(@"%@", self.isVegetarian);
    
    NSDictionary *parameters = @{
                                 @"allergies": self.allergiesTextField.text,
                                 @"is_vegetarian": self.isVegetarian,
                                 };

    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"PUT";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        long responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{
                NSLog(@"Update profile success");
            }
                break;
            case 403:
            default:{
                NSLog(@"Update profile failure");
                [self displayErrorInfo: operation.responseObject];
            }
        }
        NSLog(@"JSON: %@", responseObject);
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [self displayErrorInfo: operation.responseObject];
                                      }];
    
    [operation start];
}

- (void) loadUserDetails {
    User *user = [User sharedInstance];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: PROFILE_URL]];
    [request setValue: [@"Token " stringByAppendingString:user.auth_token] forHTTPHeaderField: @"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        long responseCode = [operation.response statusCode];
        switch (responseCode) {
            case 200:
            case 201:{
                self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [User sharedInstance].firstName, [User sharedInstance].lastName];
                self.allergiesTextField.text = responseObject[@"allergies"];
                [self setStateOfVegetarianButton:responseObject[@"is_vegetarian"]];
            }
                break;
            case 403:
            default:{
                [self displayErrorInfo: @"Please check your network"];
            }
        }
        NSLog(@"JSON: %@", responseObject);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    [self.allergiesTextField resignFirstResponder];
    [self updateUserDetailsOnServer];
    return YES;
}

- (void) setStateOfVegetarianButton:(NSString*)isVegetarianValueFromServer {
    if ([isVegetarianValueFromServer isEqualToString:@"N"]) {
        [self.isVegetarianButton setBackgroundColor:[UIColor redColor]];
        [self.isVegetarianButton setTitle:@"NO" forState:UIControlStateNormal];
    }
    else {
        [self.isVegetarianButton setBackgroundColor:[UIColor greenColor]];
        [self.isVegetarianButton setTitle:@"YES" forState:UIControlStateNormal];
    }
    self.isVegetarian = isVegetarianValueFromServer;
}

- (IBAction)toggleIsVegetarianDisplay:(UIButton *)sender {
    if ([self.isVegetarianButton.titleLabel.text isEqualToString:@"YES"]) {
        [self.isVegetarianButton setBackgroundColor:[UIColor redColor]];
        [self.isVegetarianButton setTitle:@"NO" forState:UIControlStateNormal];
        self.isVegetarian = @"N";
    } else {
        [self.isVegetarianButton setBackgroundColor:[UIColor greenColor]];
        [self.isVegetarianButton setTitle:@"YES" forState:UIControlStateNormal];
        self.isVegetarian = @"Y";
    }
    [self updateUserDetailsOnServer];
}
@end
