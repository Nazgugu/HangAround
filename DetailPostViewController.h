//
//  DetailPostViewController.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-14.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailPostViewController : UIViewController
@property (strong, nonatomic) NSString *postText;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *locationAddress;
@property (nonatomic) double latitude;
@property (nonatomic) double longtitude;
@property (strong, nonatomic) NSString *storeName;
@property (strong, nonatomic) UIImage *storeImage;
@property (strong, nonatomic) NSString *Name;
@end
