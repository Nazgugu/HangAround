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
#import "CDPosts.h"
#import "CDAppDelegate.h"
#import "DetailPostViewController.h"
#import "XHFeedCell3.h"

@interface PostsNearMeViewController ()<CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
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
    self.title = @"Posts Near Me";
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:0.6];
    self.tableView.delegate = self;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return isIpad ? 250 : 125;
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
    XHFeedCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell"];
    if (!cell)
    {
        cell = [[XHFeedCell3 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postCell"];
    }
    NSString *userName = [NSString stringWithFormat:@"%@",[[object objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey]];
    NSString *text = [object objectForKey:kPAWParseTextKey];
    UIColor* mainColor = [UIColor colorWithRed:28.0/255 green:158.0/255 blue:121.0/255 alpha:1.0f];
    UIColor* neutralColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    
    UIColor* mainColorLight = [UIColor colorWithRed:28.0/255 green:158.0/255 blue:121.0/255 alpha:0.4f];
    UIColor* lightColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    
    NSString* fontName = @"Avenir-Book";
    NSString* boldItalicFontName = @"Avenir-BlackOblique";
    NSString* boldFontName = @"Avenir-Black";
    
    
    cell.profileImageView.layer.cornerRadius = 10.0f;
    [cell.profileImageView.layer setMasksToBounds:YES];
    
    UIFont *nameLabelFont = [UIFont fontWithName:boldFontName size:(isIpad ? 35.0f : 17.0f)];
    
    //nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    cell.nameLabel.textColor =  mainColor;
    cell.nameLabel.font = nameLabelFont;
    
    UIFont *updateLabelFont = [UIFont fontWithName:fontName size:(isIpad ? 26.0f : 13.0f)];
    //updateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    cell.updateLabel.numberOfLines = 0;
    cell.updateLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.updateLabel.textColor =  neutralColor;
    cell.updateLabel.font = updateLabelFont;
    
    UIFont *dateLabelFont = [UIFont fontWithName:fontName size:(isIpad ? 24.0f : 12.0f)];
    //dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    cell.dateLabel.textAlignment = NSTextAlignmentRight;
    cell.dateLabel.textColor = lightColor;
    cell.dateLabel.font =  dateLabelFont;
    
    UIFont *countLabelFont = [UIFont fontWithName:boldItalicFontName size:(isIpad ? 20.0f : 10.0f)];
    //commentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    cell.commentCountLabel.textColor = mainColorLight;
    cell.commentCountLabel.font = countLabelFont;
    
    //likeCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    cell.likeCountLabel.textColor = mainColorLight;
    cell.likeCountLabel.font = countLabelFont;

    cell.updateLabel.text = text;
    cell.nameLabel.text = userName;
    cell.dateLabel.text = @"1 hr ago";
    cell.likeCountLabel.text = @"293 likes";
    cell.commentCountLabel.text = @"555K comments";
    [cell.profileImageView setImage:[UIImage imageNamed:@"default_profile_4"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
                              [cell.profileImageView setImage:[UIImage imageWithData:imageData]];
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
    NSLog(@"did select %ld",(long)indexPath.row);
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]])
    {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc forSegue:@"detailPost" fromIndexPath:indexPath];
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
    [self prepareViewController:segue.destinationViewController forSegue:@"detailPost" fromIndexPath:indexPath];
}

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath
{
    if ([vc isKindOfClass:[DetailPostViewController class]])
    {
        DetailPostViewController *detailPostVC = (DetailPostViewController *)vc;
        if ([[self.tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[XHFeedCell3 class]])
        {
            XHFeedCell3 *selectedCell = (XHFeedCell3 *)[self.tableView cellForRowAtIndexPath:indexPath];
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
