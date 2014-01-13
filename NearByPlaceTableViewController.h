//
//  NearByPlaceTableViewController.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-12.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearByPlaceTableViewController : UITableViewController <UITableViewDataSource>
@property (nonatomic) double latitude;
@property (nonatomic) double longtitude;
@property (strong, nonatomic) NSString *typeString;
@end
