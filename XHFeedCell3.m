//
//  XHFeedCell3.m
//  XHFeed
//
//  Created by 曾 宪华 on 13-12-12.
//  Copyright (c) 2013年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507. All rights reserved.
//

#import "XHFeedCell3.h"

@implementation XHFeedCell3

@synthesize updateLabel, nameLabel, profileImageView, dateLabel, commentCountLabel, likeCountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
                
#define profileImageViewX (isIpad ? 40 :20)
#define profileImageViewY (isIpad ? 22 :11)
#define profileImageViewSize (isIpad ? 80 :40)
        
#define nameLabelX (isIpad ? 170 : 68)
#define nameLabelWidth (isIpad ? 432 : 216)
#define nameLabelHeight (isIpad ? 42 : 21)
        
        // 内容的
#define updateLabelY (isIpad ? 64 : 32)
#define updateLabelWidth (isIpad ? 550 : 238)
#define updateLabelHeight (isIpad ? 120 : 60)
        
#define commentCountLabelY (isIpad ? 186 : 93)
#define commentCountLabelWidth (isIpad ? 160 : 77)
#define commentCountLabelHeight (isIpad ? 42 : 21)
        
#define likeCountLabelSpeator (isIpad ? 60 : 10)
        
#define dateLabelSpeator (isIpad ? 10 : 5)
        
        profileImageView.frame = CGRectMake(profileImageViewX, profileImageViewY, profileImageViewSize, profileImageViewSize);
        nameLabel.frame = CGRectMake(nameLabelX, profileImageView.frame.origin.y, nameLabelWidth, nameLabelHeight);
        updateLabel.frame = CGRectMake(nameLabel.frame.origin.x, updateLabelY, updateLabelWidth, updateLabelHeight);
        commentCountLabel.frame = CGRectMake(nameLabel.frame.origin.x, commentCountLabelY, commentCountLabelWidth, commentCountLabelHeight);
        likeCountLabel.frame = CGRectMake(commentCountLabel.frame.origin.x + commentCountLabel.frame.size.width + likeCountLabelSpeator, commentCountLabel.frame.origin.y, commentCountLabel.frame.size.width, commentCountLabel.frame.size.height);
        dateLabel.frame = CGRectMake(likeCountLabel.frame.origin.x + likeCountLabel.frame.size.width + dateLabelSpeator, commentCountLabel.frame.origin.y, commentCountLabel.frame.size.width, commentCountLabel.frame.size.height);
        
        self.userInteractionEnabled = YES;
        
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
