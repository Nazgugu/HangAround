//
//  PersonalDetailViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-15.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "PersonalDetailViewController.h"

@interface PersonalDetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@end

@implementation PersonalDetailViewController
@synthesize avatarImage,usernameLabel,emailLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [avatarImage setImage:self.avatar];
    [usernameLabel setText:self.userName];
    [emailLabel setText:[NSString stringWithFormat:@"Email: %@",self.userEmail]];
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

@end
