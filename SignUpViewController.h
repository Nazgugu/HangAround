//
//  SignUpViewController.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTextField.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface SignUpViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UITextField *Email;
- (IBAction)SignUp:(id)sender;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@end
