//
//  CDAnnotation.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-14.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "CDAnnotation.h"
@interface CDAnnotation()
@end

@implementation CDAnnotation

- (id)initWithTitle:(NSString *)title Location:(CLLocationCoordinate2D)location
{
    self = [super init];
    if (self)
    {
        _title = title;
        _coordinate = location;
    }
    return  self;
}

@end

