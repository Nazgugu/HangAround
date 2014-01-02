//
//  HomeViewController.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *Username;
- (IBAction)Logout:(id)sender;

@end
