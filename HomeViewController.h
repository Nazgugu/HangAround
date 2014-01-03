//
//  HomeViewController.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBPathImageView.h"

@interface HomeViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *Username;
@property (strong, nonatomic) IBOutlet GBPathImageView *UserImage;

- (IBAction)Logout:(id)sender;
@end
