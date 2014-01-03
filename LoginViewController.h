//
//  LoginViewController.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *UserName;
@property (weak, nonatomic) IBOutlet UITextField *PassWord;
- (IBAction)Login:(id)sender;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;


@end
