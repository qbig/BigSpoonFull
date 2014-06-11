//
//  AuthViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController (){
    NSMutableData *_responseData;
    int statusCode;
}

@end

@implementation SignUpViewController

@synthesize activityIndicator;
@synthesize submitButton;
@synthesize firstNameLabel;
@synthesize emailAddressLabel;
@synthesize passwordLabel;
@synthesize navigationItem;
@synthesize mainView;
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
    
    // set background color
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.mainView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:172 green:234 blue:241 alpha:0] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.mainView.layer insertSublayer:gradient atIndex:0];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:172.0f/255.0 green:234.0/255.0 blue:241.0/255.0 alpha:0];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.signupLabel setFont: [UIFont fontWithName:@"copyfonts.com_segoe_ui_light" size:20]];
    [self.backButton.titleLabel setFont:[UIFont fontWithName:@"copyfonts.com_segoe_ui_light" size:15]];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proceedToOutletView) name:FB_TOKEN_VERIFIED object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)textFieldDidBeginEditing:(id)sender {
    
        //move the main view, so that the keyboard does not hide it.
    if  (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES withDistance:OFFSET_FOR_KEYBOARD_SIGN_UP];
    }
}

- (IBAction)textFinishEditing:(id)sender {
    
    [sender resignFirstResponder];
    
    //move the main view, so that the keyboard does not hide it.
    if  (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO withDistance:OFFSET_FOR_KEYBOARD_SIGN_UP];
    }
}

- (IBAction)submitButtonPressed:(id)sender {
    
    
    if ([firstNameLabel.text isEqualToString:@""] ||
        [emailAddressLabel.text isEqualToString:@""] || [passwordLabel.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Oops"
                                  message:@"Please make sure you've filled up the form"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        [[Mixpanel sharedInstance] track:@"clicked 'Done' in signup page with blank field"];
        return;
    }
    
    NSError* error;
    [self showLoadingIndicators];
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:USER_SIGNUP]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject: self.firstNameLabel.text forKey: @"first_name"];
    [info setObject: self.passwordLabel.text forKey: @"password"];
    [info setObject: self.emailAddressLabel.text forKey: @"email"];
    if (self.facebookUserName) {
        [info setObject:self.facebookUserName forKey:@"username"];
    }
    
    if (self.facebookUserName != nil && [self.facebookUserName isEqualToString:@""]) {
        [info setObject:self.facebookUserName forKey:@"username"];
        NSLog(@"User signed up through Facebook. Username: %@", self.facebookUserName);
    }
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    request.HTTPBody = jsonData;
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    statusCode = [response statusCode];
    
    //NSDictionary* headers = [response allHeaderFields];

    NSLog(@"response code for sign up: %d",  statusCode);
    
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
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:_responseData
                          
                          options:kNilOptions
                          error:&error];
    
//        for (id key in [json allKeys]){
//            NSString* obj =(NSString *) [json objectForKey: key];
//            NSLog(obj);
//        }
    
    [self stopLoadingIndicators];

    switch (statusCode) {
        
        // 201 Created
        case 201:{

            NSString* email =[json objectForKey:@"email"];
            NSString* firstName = [json objectForKey:@"first_name"];
            NSString* lastName = [json objectForKey:@"last_name"];
            NSString* auth_token = [json objectForKey:@"auth_token"];
            NSString* profilePhotoURL = [json objectForKey:@"avatar_url"];
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel identify:mixpanel.distinctId];
            [mixpanel createAlias:email
                    forDistinctID:mixpanel.distinctId];
            [mixpanel registerSuperProperties:@{@"First Name": firstName,
                                                @"Last Name" : lastName,
                                                @"Email" : email
                                                }];
            [mixpanel.people set:@"$email" to:email];
            
            User *user = [User sharedInstance];
            user.firstName = firstName;
            user.lastName = lastName;
            user.email = email;
            user.authToken = auth_token;
            user.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: profilePhotoURL]]];
            
            NSLog(@"New user created:");
            NSLog(@"FirstName: %@, LastName: %@", firstName, lastName);
            NSLog(@"Email: %@", email);
            NSLog(@"Auth_token: %@", auth_token);
            NSLog(@"ProfilePhotoURL: %@", profilePhotoURL);
            
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            // Set
            [prefs setObject:firstName forKey:@"firstName"];
            [prefs setObject:lastName forKey:@"lastName"];
            [prefs setObject:email forKey:@"email"];
            [prefs setObject:profilePhotoURL forKey:@"profilePhotoURL"];
            [prefs synchronize];
            [SSKeychain setPassword:auth_token forService:@"BigSpoon" account:email];

            [User sharedInstance].isLoggedIn = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:FB_TOKEN_VERIFIED object:nil];
            
            break;
        }
            
        default:{
            [[Mixpanel sharedInstance] track:@"signup fail"];
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
    NSLog(@"NSURLCoonection encounters error at creating users.");
    
    NSLog(@"NSURLCoonection encounters error at retrieving outlits.");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Failed to sign up. Please check your network."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles: nil];
    [alertView show];
}

#pragma mark Show and hide indicators

- (void) showLoadingIndicators{
    [[self submitButton] setEnabled: NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect frame = activityIndicator.frame;
    activityIndicator.frame = CGRectMake(frame.origin.x, screenHeight / 2 - 30, frame.size.width, frame.size.height);
    [activityIndicator startAnimating];
}

- (void) stopLoadingIndicators{
    [[self submitButton] setEnabled: YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [activityIndicator stopAnimating];
}

#pragma mark fb

- (void)proceedToOutletView{
    [self stopLoadingIndicators];
    [User sharedInstance].isLoggedIn = YES;
    [self performSegueWithIdentifier:@"SegueFromSingUpToOutlets" sender:self];
}



- (IBAction)fbButtonPressed:(id)sender {
    [self showLoadingIndicators];
    [[User sharedInstance] attemptToLoginToFB];
}

@end
