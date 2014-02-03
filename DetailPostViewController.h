//
//  DetailPostViewController.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-14.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGFoursquareLocationDetail.h"
#import "DetailLocationCell.h"
#import "AddressLocationCell.h"
#import "UserCell.h"
#import "TipCell.h"
#import "TGAnnotation.h"

@interface DetailPostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TGFoursquareLocationDetailDelegate, KIImagePagerDelegate, KIImagePagerDataSource>


@property (nonatomic, strong) TGFoursquareLocationDetail *locationDetail;
@property (nonatomic, strong) MKMapView *map;
@property (strong, nonatomic) NSString *postText;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *locationAddress;
@property (nonatomic) double latitude;
@property (nonatomic) double longtitude;
@property (strong, nonatomic) NSString *storeName;
@property (strong, nonatomic) UIImage *storeImage;
@property (strong, nonatomic) NSString *Name;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) NSString *actTime;
@end
