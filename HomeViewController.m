//
//  HomeViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>

@interface HomeViewController ()

@end

@implementation HomeViewController

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
    [self.UserImage setPathColor:[UIColor whiteColor]];
    [self.UserImage setBorderColor:[UIColor blackColor]];
    [self.UserImage setPathWidth:2.5];
    [self.UserImage setPathType:GBPathImageViewTypeCircle];
    [self.UserImage draw];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PFUser currentUser]) {
        self.Username.text = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), [[PFUser currentUser] username]];
    }
    else {
        self.Username.text = NSLocalizedString(@"Not logged in", nil);
    }
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

- (IBAction)Logout:(id)sender {
    [PFUser logOut];
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"LogoutUser" sender:self];

}

#pragma actionsheets
- (IBAction)showAvatar:(UITapGestureRecognizer*)sender {
    UIActionSheet *selectImage = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Image", @"Select Image", nil];
    [selectImage showInView:self.view];
        selectImage.tag = 1;
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        if (buttonIndex == 0)
        {
            
        }
        if (buttonIndex == 1)
        {
            UIActionSheet *chooseFrom = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Camara", @"Choose from library", nil];
            chooseFrom.tag = 2;
            [chooseFrom showInView:self.view];
        }
    }
    if (actionSheet.tag == 2)
    {
        
    }
}



@end
