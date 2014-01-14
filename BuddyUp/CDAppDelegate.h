//
//  CDAppDelegate.h
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//
static NSUInteger const kPAWWallPostMaximumCharacterCount = 60;
static NSUInteger const kPAWWallPostsSearch = 20;

// Parse API key constants:
static NSString * const kPAWParsePostsClassKey = @"Posts";
static NSString * const kPAWParseUserKey = @"user";
static NSString * const kPAWParseUsernameKey = @"username";
static NSString * const kPAWParseTextKey = @"text";
static NSString * const kPAWParseLocationKey = @"location";
static NSString * const kPAWParseTimeKey = @"time";
static NSString * const kPAWParseTypeKey = @"category";
static NSString * const kPAWParseLocationNameKey = @"locName";

// NSNotification userInfo keys:
static NSString * const kPAWFilterDistanceKey = @"filterDistance";
static NSString * const kPAWLocationKey = @"location";

//Notification Name
static NSString * const kPAWLocationChangeNotification = @"kPAWLocationChangeNotification";
static NSString * const kPAWPostCreatedNotification = @"kPAWPostCreatedNotification";

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@end
