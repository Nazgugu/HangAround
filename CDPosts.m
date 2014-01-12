//
//  CDPosts.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-11.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "CDPosts.h"

@interface CDPosts()
@end


@implementation CDPosts

+ (NSString *)convertType:(NSUInteger)typeIndex
{
    NSArray *array = [[NSArray alloc] initWithObjects:@"Entertainment",@"Sports",@"Shopping", @"Meal", nil];
    NSString *typeString = [array objectAtIndex:typeIndex];
    return typeString;
}

@end
