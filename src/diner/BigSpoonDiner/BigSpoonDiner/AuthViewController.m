//
//  AuthViewController.m
//  BigSpoonDiner
//
//  Created by Zhixing Yang on 27/10/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "AuthViewController.h"

@interface AuthViewController ()

@end

@implementation AuthViewController

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
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   
    // Comment this line to enable the saving of user data:
     [prefs setObject:nil forKey:@"firstName"];
    
    NSString *firstName = [prefs stringForKey:@"firstName"];
    NSString *lastName = [prefs stringForKey:@"lastName"];
    NSString *email = [prefs stringForKey:@"email"];
    NSString *profilePhotoURL = [prefs stringForKey:@"profilePhotoURL"];
    NSString *auth_token = [SSKeychain passwordForService:@"BigSpoon" account:email];
    // birthday is not supported for now
    
    NSLog(@"fistName: %@, lastName: %@, email: %@, auth_token: %@, profilePhotoURL: %@", firstName, lastName, email, auth_token, profilePhotoURL);
    
    if (firstName != nil && lastName != nil && email != nil && auth_token != nil && profilePhotoURL != nil) {
        User *user = [User sharedInstance];
        user.firstName = firstName;
        user.lastName = lastName;
        user.email = email;
        user.auth_token = auth_token;
        user.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: profilePhotoURL]]];
        
        [self performSegueWithIdentifier:@"SegueFromStartToOutlets" sender:self];
        
        NSLog(@"The user logged in before");
    } else{
        NSLog(@"New user, haven't logged in before");
        [self performSegueWithIdentifier:@"SegueFromStartToLogin" sender:self];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
