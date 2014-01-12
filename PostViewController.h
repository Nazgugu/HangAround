//
//  PostViewController.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-4.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMDateSelectionViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface PostViewController : UIViewController<RMDateSelectionViewControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *characterCount;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *keyBoardAvoidingScrollView;
@property (strong, nonatomic) IBOutlet UITextField *dateSelection;
@property (strong, nonatomic) IBOutlet UITextField *locationText;
@end
