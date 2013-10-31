//
//  ProfileViewController.m
//  BigSpoonDiner
//
//  Created by Shubham Goyal on 27/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
- (void) loadUserDetails;
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
                NSLog(@"Success");
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

@end
