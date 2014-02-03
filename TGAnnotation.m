//
//  TGAnnotation.m
//  TGFoursquareLocationDetail-Demo
//
//  Created by Thibault Guégan on 19/12/2013.
//  Copyright (c) 2013 Thibault Guégan. All rights reserved.
//

#import "TGAnnotation.h"

@implementation TGAnnotation

@synthesize coordinate,title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)paramCoordinates andTitle:(NSString *)addTitile{
    self = [super init];
    if (self) {
        coordinate = paramCoordinates;
        title = addTitile;
    }
    return self;
}

@end
