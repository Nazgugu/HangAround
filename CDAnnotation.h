//
//  CDAnnotation.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-14.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CDAnnotation : NSObject<MKAnnotation>
@property (copy, nonatomic) NSString *title;
@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
- (id)initWithTitle:(NSString *)title Location:(CLLocationCoordinate2D)location;
@end
