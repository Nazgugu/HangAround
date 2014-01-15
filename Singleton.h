//
//  Singleton.h
//  HandsUp
//
//  Created by Yiming Jiang on 1/4/14.
//  Copyright (c) 2014 Yiming Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject
@property (strong, nonatomic) NSString *textString;
@property (strong, nonatomic) NSString *locationString;
@property (nonatomic) NSUInteger typeIndex;
@property (nonatomic) double latitude;
@property (nonatomic) double longtitude;
@property (strong, nonatomic) NSString *timeString;
@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) NSString *addName;

+(Singleton *)globalData;

@end
