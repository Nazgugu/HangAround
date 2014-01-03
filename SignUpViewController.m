//
//  SignUpViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>


@interface SignUpViewController ()
@end

@implementation SignUpViewController
@synthesize Username;
@synthesize Password;
@synthesize Email;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView contentSizeToFit];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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

- (IBAction)SignUp:(id)sender {
    PFUser *newUser = [PFUser user];
    newUser.username = Username.text;
    newUser.password = Password.text;
    newUser.email = Email.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error)
         {
             NSString *errorString = [[error userInfo] objectForKey:@"error"];
             UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"Try Again"
                                                        otherButtonTitles: nil];
             [errorAlert show];
         }
         else
         {
             [self performSegueWithIdentifier:@"SignupSucceed" sender:sender];
         }
     }
     ];

}
@end
