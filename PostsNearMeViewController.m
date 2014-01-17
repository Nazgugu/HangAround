//
//  PostsNearMeViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-11.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//


#import "PostsNearMeViewController.h"
#import <MapKit/MapKit.h>
#import "UITableView+Frames.h"
#import "CDCustomCell.h"
#import "CDPosts.h"
#import "CDAppDelegate.h"
#import "DetailPostViewController.h"

@interface PostsNearMeViewController ()<CLLocationManagerDelegate, UITableViewDataSource>
{
    CLLocationManager *locationManager;
}
- (void)locationDidChange:(NSNotification *)note;
- (void)postWasCreated:(NSNotification *)note;

@end

@implementation PostsNearMeViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self)
    {
        self.parseClassName = kPAWParsePostsClassKey;
        self.textKey = kPAWParseTextKey;
        if (NSClassFromString(@"UIRefreshControl"))
        {
            self.pullToRefreshEnabled = NO;
        }
        else
        {
            self.pullToRefreshEnabled = YES;
        }
        self.paginationEnabled = YES;
    
    // The number of objects to show per page
        self.objectsPerPage = kPAWWallPostsSearch;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Can you see me 1?");
    // Do any additional setup after loading the view.
    if (NSClassFromString(@"UIRefreshControl"))
    {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor blueColor];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 50.0f;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kPAWLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPAWPostCreatedNotification object:nil];
}

- (void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    // This method is called every time objects are loaded from Parse via the PFQuery

    if (NSClassFromString(@"UIRefreshControl"))
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)objectsWillLoad
{   // This method is called before a PFQuery is fired to get more objects

    [super objectsWillLoad];
}
// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    // If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.objects count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
    // Query for posts near our current location.
    
	// Get our current location:
    CLLocation *currentLocation = locationManager.location;
    CLLocationAccuracy filterDistance = 5000;
    PFGeoPoint *point =  [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    [query whereKey:kPAWParseLocationKey nearGeoPoint:point withinKilometers:filterDistance/1000];
    [query whereKey:kPAWParseUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kPAWParseUserKey];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    CDCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell"];
    if (!cell)
    {
        cell = [[CDCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postCell"];
    }
    NSString *userName = [NSString stringWithFormat:@"%@",[[object objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey]];
    NSString *text = [object objectForKey:kPAWParseTextKey];
    cell.Title.text = text;
    cell.UserName.text = userName;
    [cell.AvatarImage setImage:[UIImage imageNamed:@"default_profile_4"]];
    
    //get the avartar from web
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    
        
    PFQuery *getAvatar = [PFQuery queryWithClassName:@"UserPhoto"];
    [getAvatar whereKey:@"user" equalTo:[object objectForKey:kPAWParseUserKey]];
    [getAvatar findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             if ([objects count] > 0)
             {
                 PFObject *tempObj = [objects lastObject];
                 [getAvatar getObjectInBackgroundWithId:tempObj.objectId block:^(PFObject *avatar, NSError *error)
                  {
                     if (!error)
                     {
                         PFFile *imageFile = [avatar objectForKey:@"imageFile"];
                         [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
                          {
                              [cell.AvatarImage setImage:[UIImage imageWithData:imageData]];
                          }];
                     }
                  }];
             }
         }
         else
         {
             NSLog(@"%@ , %@",error,[error userInfo]);
         }
     }];
                   });
    //set details to each cell object
    if (!cell.detailPost)
    {
        cell.detailPost = [[CDPosts alloc] init];
        cell.detailPost.text = text;
        cell.detailPost.user = userName;
        cell.detailPost.type = [CDPosts convertType:[[object objectForKey:kPAWParseTypeKey] intValue]];
        cell.detailPost.time = [object objectForKey:kPAWParseTimeKey];
        cell.detailPost.addName = [object objectForKey:kPAWParseLocationAddressKey];
        cell.detailPost.storeName = [object objectForKey:kPAWParseLocationNameKey];
        PFGeoPoint *point = [object objectForKey:kPAWParseLocationKey];
        cell.detailPost.latitude = point.latitude;
        cell.detailPost.longtitude = point.longitude;
    }
    return cell;
}



- (NSUInteger)numberOfSectionInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableview:(UITableView *)tableView didSelectRowAtIndexPath:
    (NSIndexPath *)indexPath
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]])
    {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc forSegue:nil fromIndexPath:indexPath];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}


- (void)locationDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)postWasCreated:(NSNotification *)note {
	[self loadObjects];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadObjects];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]])
    {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController forSegue:segue.identifier fromIndexPath:indexPath];
}

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath
{
    if ([vc isKindOfClass:[DetailPostViewController class]])
    {
        DetailPostViewController *detailPostVC = (DetailPostViewController *)vc;
        if ([[self.tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[CDCustomCell class]])
        {
            CDCustomCell *selectedCell = (CDCustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            NSLog(@"%@\n%@\n%@\n%@\n%@\n%f\n%f\n",selectedCell.detailPost.text,selectedCell.detailPost.user,selectedCell.detailPost.type,selectedCell.detailPost.addName,selectedCell.detailPost.storeName,selectedCell.detailPost.latitude,selectedCell.detailPost.longtitude);
            detailPostVC.postText = selectedCell.detailPost.text;
            detailPostVC.type = selectedCell.detailPost.type;
            detailPostVC.locationAddress = selectedCell.detailPost.addName;
            detailPostVC.latitude = selectedCell.detailPost.latitude;
            detailPostVC.longtitude = selectedCell.detailPost.longtitude;
            detailPostVC.storeName = selectedCell.detailPost.storeName;
            detailPostVC.Name = selectedCell.detailPost.user;
            detailPostVC.actTime = selectedCell.detailPost.time;
        }
    }
}

@end
