//
//  CDPosts.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-11.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDPosts : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *time;
+ (NSString *)convertType:(NSUInteger)typeIndex;
@end
