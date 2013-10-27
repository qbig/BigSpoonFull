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

@end

@implementation LoginViewController

@synthesize emailLabel;
@synthesize passwordField;
@synthesize activityIndicator;

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
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
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
    
    NSLog(@"response code: %d",  statusCode);
    
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
            
        // 200 Okay
        case 200:{

            NSString* email =[json objectForKey:@"email"];
            NSString* firstName = [json objectForKey:@"first_name"];
            NSString* lastName = [json objectForKey:@"last_name"];
            NSString* auth_token = [json objectForKey:@"auth_token"];
            

            User *user = [User sharedInstance];
            user.firstName = firstName;
            user.lastName = lastName;
            user.email = email;
            user.auth_token = auth_token;

            NSLog(@"User logged in:");
            NSLog(@"FirstName: %@, LastName: %@", firstName, lastName);
            NSLog(@"Email: %@", email);
            NSLog(@"Auth_token: %@", auth_token);
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            // Set
            [prefs setObject:firstName forKey:@"firstName"];
            [prefs setObject:lastName forKey:@"lastName"];
            [prefs setObject:email forKey:@"email"];
            [prefs synchronize];
            [SSKeychain setPassword:auth_token forService:@"BigSpoon" account:email];
            

            [self performSegueWithIdentifier:@"SegueOnSuccessfulLogin" sender:self];
            
            break;
        }
            
        default:{
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops" message: @"Unable to login with provided credentials." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
}


#pragma mark Show and hide indicators

- (void) showLoadingIndicators{
    [[self submitButton] setEnabled: NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [activityIndicator startAnimating];
}

- (void) stopLoadingIndicators{
    [[self submitButton] setEnabled: YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [activityIndicator stopAnimating];
}

#pragma mark fbLogin

- (IBAction)fbButtonPressed:(id)sender {
    
    if (FBSession.activeSession.isOpen) {
        NSLog(@"FBSession.activeSession.isOpen IS open!");
        [self performSegueWithIdentifier:@"SegueFromLoginToSignup" sender:self];
    }else{
        NSLog(@"FBSession.activeSession.isOpen NOT open!");
        [self openSession];
    }
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error{
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"Successfully logged in with Facebook");
            if (FBSession.activeSession.isOpen) {
                NSLog(@"YAY! Finally Become open!");
                [self performSegueWithIdentifier:@"SegueFromLoginToSignup" sender:self];
            } else{
                NSLog(@"Nope not yet");
            }
        }
            break;
        case FBSessionStateClosed:{
            NSLog(@"FBSessionStateClosed");
        }
            break;
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            NSLog(@"Failed logging with Facebook");
            [FBSession.activeSession closeAndClearTokenInformation];
            
            break;
        default:
            NSLog(@"Other cases");
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSession
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", @"basic_info", nil];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
         
         FBSession.activeSession = session;
     }];
}
@end
