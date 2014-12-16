//
//  LoginViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 15/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "LoginViewController.h"
#import "Reachability.h"
#import "Constants.h"
#import <Crashlytics/Crashlytics.h>
@interface LoginViewController (){
    NSMutableData *_responseData;
    Reachability *internetReachableFoo;
    int statusCode;
}

@property NSURLConnection* connectionForCheckingFBToken;
@end

@implementation LoginViewController

@synthesize activityIndicator;
@synthesize mainView;
@synthesize connectionForCheckingFBToken;
@synthesize intro;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proceedToOutletView) name:FB_TOKEN_VERIFIED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbLoginFailureHandler) name:NOTIF_FB_LOGIN_FAILED object:nil];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:KEY_FOR_SHOW_TUT_DEFAULT]){
        [self showIntroWithCustomView];
    }
    [self stopLoadingIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)showIntroWithCustomView {
    [[Mixpanel sharedInstance] track:@"OutletView: User start tutorial"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSMutableArray *pagesToAdd = [[NSMutableArray alloc] init];
    int numOfPagesInTutorial = 5;
    NSString *imageNameformat;
    if( IS_IPHONE_5_OR_LARGER ){
        imageNameformat = @"new-intro-%d_long.png";
    } else {
        imageNameformat = @"new-intro-%d.png";
    }
    
    for(int i = 0; i < numOfPagesInTutorial; i++){
        UIImageView *viewForPage = [[UIImageView alloc] initWithImage:
                                    [UIImage imageNamed: [NSString stringWithFormat:imageNameformat, i]]
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

}

- (void)proceedToOutletView {
    [self stopLoadingIndicators];
    [self performSegueWithIdentifier:@"SegueOnSuccessfulLogin" sender:self];
    [User sharedInstance].isLoggedIn = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

#pragma mark Show and hide indicators

- (void) showLoadingIndicators {
    [self.fbButton setEnabled:NO];
    [self.signupButton setEnabled:NO];
    [self.loginButton setEnabled:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [activityIndicator startAnimating];
}

- (void) stopLoadingIndicators {
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
    [[User sharedInstance].userDefault setBool:YES forKey:KEY_FOR_SHOW_TUT_DEFAULT];
    [self askForLocationPermit];
    [[Mixpanel sharedInstance] track:@"OutletView: User Finish Tutorial"];
}
@end
