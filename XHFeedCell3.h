//
//  XHFeedCell3.h
//  XHFeed
//
//  Created by 曾 宪华 on 13-12-12.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDPosts.h"

@interface XHFeedCell3 : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView* profileImageView;

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;

@property (nonatomic, strong) IBOutlet UILabel* updateLabel;

@property (nonatomic, strong) IBOutlet UILabel* dateLabel;

@property (nonatomic, strong) IBOutlet UILabel* commentCountLabel;

@property (nonatomic, strong) IBOutlet UILabel* likeCountLabel;

@property (strong, nonatomic) CDPosts *detailPost;

@end
