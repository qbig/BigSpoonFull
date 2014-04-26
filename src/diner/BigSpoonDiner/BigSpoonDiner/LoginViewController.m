//
//  LoginViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "LoginViewController.h"
#import "Reachability.h"

@interface LoginViewController (){
    NSMutableData *_responseData;
    Reachability *internetReachableFoo;
    int statusCode;
}

@property NSURLConnection* connectionForCheckingFBToken;
@end

@implementation LoginViewController

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@synthesize activityIndicator;
@synthesize mainView;
@synthesize connectionForCheckingFBToken;
@synthesize intro;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbLoginFailureHandler) name:NOTIF_NEW_DISH_INFO_FAILED object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proceedToOutletView) name:FB_TOKEN_VERIFIED object:nil];
    [super viewWillAppear:animated];
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    if(![userDefault boolForKey:KEY_FOR_SHOW_TUT_DEFAULT]){
        [self showIntroWithCustomView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)showIntroWithCustomView {
    [[Mixpanel sharedInstance] track:@"OutletView: User start tutorial"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSMutableArray *pagesToAdd = [[NSMutableArray alloc] init];
    int numOfPagesInTutorial = 5;
    NSString *imageNameformat;
    if( IS_IPHONE_5 ){
        imageNameformat = @"intro_%d_long.png";
    } else {
        imageNameformat = @"intro_%d.png";
    }
    
    for(int i = 0; i < numOfPagesInTutorial; i++){
        UIImageView *viewForPage = [[UIImageView alloc] initWithImage:
                                    [UIImage imageNamed: [NSString stringWithFormat:imageNameformat, (i+1)]]
                                   ];
        viewForPage.frame = self.view.frame;
        [pagesToAdd addObject:[EAIntroPage pageWithCustomView:viewForPage]];
    }
    
    self.intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:pagesToAdd];
    
    [self.intro setDelegate:self];
    [self.intro showInView:self.view animateDuration:0.3];
}

- (void) askForLocationPermit{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SHOULD_ASK_LOCATION_PERMIT_NOT object:nil];
    NSLog(@"location bt clicked");
}

- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
}

- (void) fbLoginFailureHandler{
    [self stopLoadingIndicators];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is embarrassing"
                                                        message:@"Facebook login failed. Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

- (void)proceedToOutletView{
    [self stopLoadingIndicators];
    [self performSegueWithIdentifier:@"SegueOnSuccessfulLogin" sender:self];
    [User sharedInstance].isLoggedIn = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

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
    [self.fbButton setEnabled:NO];
    [self.signupButton setEnabled:NO];
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
    [self.fbButton setEnabled:YES];
    [self.signupButton setEnabled:YES];
    [self.loginButton setEnabled:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [activityIndicator stopAnimating];
}

#pragma mark fbLogin

- (IBAction)fbButtonPressed:(id)sender {
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    __weak id weakSelf = self;
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoadingIndicators];
            [[User sharedInstance] attemptToLoginToFB];
            [[Mixpanel sharedInstance] track:@"Try to login using FB"];
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Unavailable"
                                                                message:@"Try again when you are connected."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            [alertView show];

        });
    };
    
    [internetReachableFoo startNotifier];
}

#pragma mark - Intro

- (void)introDidFinish {
    [self.intro removeFromSuperview];
    [self askForLocationPermit];
    [[User sharedInstance].userDefault setBool:YES forKey:KEY_FOR_SHOW_TUT_DEFAULT];
    [[Mixpanel sharedInstance] track:@"OutletView: User Finish Tutorial"];
}
@end
