//
//  Singleton.m
//  HandsUp
//
//  Created by Yiming Jiang on 1/4/14.
//  Copyright (c) 2014 Yiming Jiang. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton
@synthesize textString, locationString, typeIndex, latitude, longtitude, timeString, avatar, addName;

+ (Singleton *)globalData
{
    static Singleton * theSingleton = nil;
    if (!theSingleton) {
        theSingleton = [[super allocWithZone:nil] init];
    }
    return theSingleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self globalData];
}

- (id)init
{
    self = [super init];
    if (self) {
        textString = @"";
        locationString = @"";
        typeIndex = 0;
        latitude = 0.0f;
        longtitude = 0.0f;
        timeString = @"";
        avatar = nil;
        addName = @"";
    }
    return self;
}

@end
