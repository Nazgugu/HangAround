//
//  LoginViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>


@interface LoginViewController ()
@end

@implementation LoginViewController
@synthesize UserName;
@synthesize PassWord;
@synthesize scrollView;

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
    [self.scrollView contentSizeToFit];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)Login:(id)sender {
    [PFUser logInWithUsernameInBackground:UserName.text password:PassWord.text block:^(PFUser *user, NSError *error)
     {
         if (user)
         {
             [self performSegueWithIdentifier:@"LoginSucceed" sender:sender];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Invalid Username or Password" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
             [alert show];
         }
     }
     ];

}
@end
