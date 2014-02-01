//
//  LoginViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController (){
    NSMutableData *_responseData;
    int statusCode;
}
@property NSURLConnection* connectionForLogin;
@property NSURLConnection* connectionForCheckingFBToken;
@end

@implementation LoginViewController

@synthesize emailLabel;
@synthesize passwordField;
@synthesize activityIndicator;
@synthesize mainView;
@synthesize connectionForLogin;
@synthesize connectionForCheckingFBToken;
@synthesize taglineLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    //set background color
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.mainView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:172 green:234 blue:241 alpha:0] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.mainView.layer insertSublayer:gradient atIndex:0];
    [self.taglineLabel setFont: [UIFont fontWithName:@"copyfonts.com_segoe_ui_light" size:17]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTokenValidity) name:FB_SESSION_IS_OPEN object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)submitButtonPressed:(id)sender {

    NSError* error;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:USER_LOGIN]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.emailLabel.text,
                          @"email",
                          self.passwordField.text,
                          @"password",
                          nil];

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                   options:NSJSONWritingPrettyPrinted error:&error];

    request.HTTPBody = jsonData;
    
    
    if ([self isTableValid]){
        // Create url connection and fire request
        [self showLoadingIndicators];
        self.connectionForLogin = [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        [[Mixpanel sharedInstance] track:@"Failed to login using email, with blank field" properties:@{@"email": self.emailLabel.text, @"password": self.passwordField.text}];
    }
    [[Mixpanel sharedInstance] track:@"Try to log in with Email" properties:@{@"email": self.emailLabel.text, @"password": self.passwordField.text}];
    [TestFlight passCheckpoint:@"CheckPoint:User Loggin in with email"];
}

- (void) checkTokenValidity {
    [self showLoadingIndicators];
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: USER_LOGIN_WITH_FB]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:[FBSession.activeSession accessTokenData].accessToken forKey: @"access_token"];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    request.HTTPBody = jsonData;
    
    // Create url connection and fire request
    self.connectionForCheckingFBToken = [NSURLConnection connectionWithRequest:request delegate:self];
}


- (BOOL) isTableValid{
    NSString *errorMessage = @"";

    if ([self.emailLabel.text length] == 0) {
        errorMessage = @"Email is required.";
       
    }
    
    if ([self.passwordField.text length] == 0) {
        errorMessage = @"Password is required.";
    }
    
    if ([self.emailLabel.text length] == 0 && [self.passwordField.text length] == 0) {
        errorMessage = @"Email and Password is required.";
    }
    
    if ([errorMessage isEqualToString:@""]) {
        
        return YES;
        
    } else{
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops" message: errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [message show];
        
        return NO;
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    statusCode = [response statusCode];
    
    //NSDictionary* headers = [response allHeaderFields];
    
    NSLog(@"response code for log in: %d",  statusCode);
    
    _responseData = [[NSMutableData alloc] init];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (void)setUserDataAndPrefsWithReturnedData:(NSDictionary *)json {
    NSLog(@"%@", json);
    NSString* email =[json objectForKey:@"email"];
    NSString* firstName = [json objectForKey:@"first_name"];
    NSString* lastName = [json objectForKey:@"last_name"];
    NSString* auth_token = [json objectForKey:@"auth_token"];
    NSString* profilePhotoURL = [json objectForKey:@"avatar_url_large"];
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
    
    
    NSLog(@"User logged in:");
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
    
    [self stopLoadingIndicators];
    
    if (connection == self.connectionForLogin) {
        switch (statusCode) {
                
                // 200 Okay
            case 200:{
                
                [self setUserDataAndPrefsWithReturnedData:json];
                
                [self performSegueWithIdentifier:@"SegueOnSuccessfulLogin" sender:self];
                [[Mixpanel sharedInstance] track:@"Log in with email success" properties:@{@"email": self.emailLabel.text, @"password": self.passwordField.text}];
                break;
            }
                
            default:{
                [[Mixpanel sharedInstance] track:@"Log in with email failure" properties:@{@"email": self.emailLabel.text, @"password": self.passwordField.text}];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops" message: @"Unable to login with provided credentials." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [message show];
                
                break;
            }
        }
    } else {
        // handle checking token connection
        if ([json count] == 6){
            [self setUserDataAndPrefsWithReturnedData:json];
            [self performSegueWithIdentifier:@"SegueOnSuccessfulLogin" sender:self];
        } else {
            [self performSegueWithIdentifier:@"SegueFromLoginToSignup" sender:self];
            [[Mixpanel sharedInstance] track:@"Signup with FB"];
        }
    }
   
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (!self.connectionForLogin){
        [[Mixpanel sharedInstance] track:@"Signup with email"];
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
    NSLog(@"NSURLCoonection encounters error at logging in.");
    
    NSLog(@"NSURLCoonection encounters error at retrieving outlits.");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                        message:@"Failed to log in. Please check your network"
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
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect frame = activityIndicator.frame;
    activityIndicator.frame = CGRectMake(screenWidth / 2, screenHeight / 2, frame.size.width, frame.size.height);
    
    [activityIndicator startAnimating];
}

- (void) stopLoadingIndicators{
    [[self submitButton] setEnabled: YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [activityIndicator stopAnimating];
}

#pragma mark fbLogin

- (IBAction)fbButtonPressed:(id)sender {
    [[User sharedInstance] attemptToLoginToFB];
    [[Mixpanel sharedInstance] track:@"Try to login using FB"];
}

@end
