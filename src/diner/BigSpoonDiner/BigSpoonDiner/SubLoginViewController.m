//
//  SubLoginViewController.m
//  BigSpoonDiner
//
//  Created by Qiao Liang on 25/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "SubLoginViewController.h"

@interface SubLoginViewController ()
@property NSURLConnection* connectionForLogin;
@property NSMutableData * responseData;
@property int statusCode;
@end

@implementation SubLoginViewController
@synthesize responseData = _responseData;
@synthesize activityIndicator;
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
    [self.loginLabel setFont: [UIFont fontWithName:@"copyfonts.com_segoe_ui_light" size:20]];
    [self.backButton.titleLabel setFont:[UIFont fontWithName:@"copyfonts.com_segoe_ui_light" size:15]];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonPressed:(id)sender {
    
    NSError* error;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:USER_LOGIN]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.emailTextField.text,
                          @"email",
                          self.passwordTextField.text,
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
        [[Mixpanel sharedInstance] track:@"Failed to login using email, with blank field" properties:@{@"email": self.emailTextField.text, @"password": self.passwordTextField.text}];
    }
    [[Mixpanel sharedInstance] track:@"Try to log in with Email" properties:@{@"email": self.emailTextField.text, @"password": self.passwordTextField.text}];
    [TestFlight passCheckpoint:@"CheckPoint:User Loggin in with email"];
}

- (BOOL) isTableValid{
    NSString *errorMessage = @"";
    
    if ([self.emailTextField.text length] == 0) {
        errorMessage = @"Email is required.";
        
    }
    
    if ([self.passwordTextField.text length] == 0) {
        errorMessage = @"Password is required.";
    }
    
    if ([self.emailTextField.text length] == 0 && [self.passwordTextField.text length] == 0) {
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
    
    self.statusCode = [response statusCode];
    
    //NSDictionary* headers = [response allHeaderFields];
    
    NSLog(@"response code for log in: %d",  self.statusCode);
    
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
    
    [self stopLoadingIndicators];
    
    if (connection == self.connectionForLogin) {
        switch (self.statusCode) {
                
                // 200 Okay
            case 200:{
                
                [self setUserDataAndPrefsWithReturnedData:json];
                
                [self performSegueWithIdentifier:@"segueLoginWithEmail" sender:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:FB_TOKEN_VERIFIED object:nil];
                [User sharedInstance].isLoggedIn = YES;
                [[Mixpanel sharedInstance] track:@"Log in with email success" properties:@{@"email": self.emailTextField.text, @"password": self.passwordTextField.text}];
                break;
            }
                
            default:{
                [[Mixpanel sharedInstance] track:@"Log in with email failure" properties:@{@"email": self.emailTextField.text, @"password": self.passwordTextField.text}];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops" message: @"Unable to login with provided credentials." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [message show];
                
                break;
            }
        }
    }
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


#pragma mark Show and hide indicators

- (void) showLoadingIndicators{
    [self.loginButton setEnabled:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect frame = activityIndicator.frame;
    activityIndicator.frame = CGRectMake(screenWidth / 2, screenHeight / 2, frame.size.width, frame.size.height);
    
    [activityIndicator startAnimating];
}

- (void) stopLoadingIndicators{
    [self.loginButton setEnabled:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [activityIndicator stopAnimating];
}


@end
