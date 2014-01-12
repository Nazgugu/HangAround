//
//  CDCustomCell.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-11.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDPosts.h"

@interface CDCustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *Title;
@property (strong, nonatomic) IBOutlet UILabel *UserName;
@property (strong, nonatomic) IBOutlet UIImageView *AvatarImage;
@property (strong, nonatomic) CDPosts *detailPost;
@end
