//
//  DetailPostViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-14.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "DetailPostViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CDAnnotation.h"
#import "AFNetworking.h"

@interface DetailPostViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *manager;
}

@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailPost;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *time;
@end

@implementation DetailPostViewController

@synthesize addressLabel, typeLabel, detailPost, userName,time;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //location manager
    manager = [[CLLocationManager alloc] init];
    manager.distanceFilter = 10.0f;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    manager.delegate = self;
    [manager startUpdatingLocation];
    self.locationDetail = [[TGFoursquareLocationDetail alloc] initWithFrame:self.view.bounds];
    self.locationDetail.tableViewDataSource = self;
    self.locationDetail.tableViewDelegate = self;
    
    self.locationDetail.delegate = self;
    self.locationDetail.parallaxScrollFactor = 0.3;
    // little slower than normal.
    
    self.locationDetail.headerView = _headerView;
    
    [self.view addSubview:self.locationDetail];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.view bringSubviewToFront:_headerView];

    [detailPost setText:self.postText];
    
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.frame = CGRectMake(10, 22, 44, 44);
    [buttonBack setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [buttonBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonBack];
    
    UIButton *buttonPost = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonPost.frame = CGRectMake(self.view.bounds.size.width - 44, 18, 44, 44);
    [buttonPost setImage:[UIImage imageNamed:@"btn_post"] forState:UIControlStateNormal];
    [buttonPost addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonPost];

    
    if ([self.locationAddress isEqualToString:@""])
    {
        NSLog(@"No address provided");
    }
    else
    {
        [addressLabel setText:self.locationAddress];
    }
    [typeLabel setText:self.type];
    NSString *postCreater = [NSString stringWithFormat:@"By %@",self.Name];
    [userName setText:postCreater];
    // for mapivew
    [time setText:self.actTime];
    // Do any additional setup after loading the view.
    //annotation
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
        if (annotation == mapView.userLocation)
        {
            return nil;
        }
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"storePin"];
        if (!annotationView)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"storePin"];
            annotationView.canShowCallout = YES;
            //annotationView.enabled = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
            imageView.image = self.storeImage;
            annotationView.leftCalloutAccessoryView = imageView;
            annotationView.image = [UIImage imageNamed:@"pin_map_blue"];
        }
        annotationView.annotation = annotation;
        return  annotationView;
}

/*- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D coord = [userLocation coordinate];
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 138.0f;
    }
    else if(indexPath.row == 1){
        return 171.0f;
    }
    else if(indexPath.row == 2){
        return 138.0f;
    }
    else
    return 100.0f; //cell for comments, in reality the height has to be adjustable
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0){
        DetailLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailLocationCell"];
        
        if(cell == nil){
            cell = [DetailLocationCell detailLocationCell];
        }
        return cell;
    }
    else if(indexPath.row == 1){
        AddressLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressLocationDetail"];
        
        if(cell == nil){
            cell = [AddressLocationCell addressLocationDetailCell];
            _map = [[MKMapView alloc] initWithFrame:CGRectMake(179, 0, 141, 171)];
            _map.userInteractionEnabled = YES;
            _map.delegate = self;
            MKCoordinateRegion myRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.latitude, self.longtitude), 5000, 5000);
            [_map setShowsUserLocation:YES];
            // move the map to our location
            [_map setRegion:myRegion animated:YES];
            
            //annotation
            TGAnnotation *annot = [[TGAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longtitude) andTitle:self.storeName];
            [_map addAnnotation:annot];
            
            [cell.contentView addSubview:_map];
        }
        
        return cell;
    }
    else if(indexPath.row == 2){
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
        
        if(cell == nil){
            cell = [UserCell userCell];
        }
        return cell;
    }
    else if(indexPath.row == 3){
        TipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tipCell"];
        
        if(cell == nil){
            cell = [TipCell tipCell];
            cell.titleLbl.text = @"Eymundsson says:";
            cell.contentLbl.text = @"The city of Reykjavik, Iceland, has been designated as UNESCO City of Literature. How great is that!";
        }
        return cell;
    }
    else if(indexPath.row == 4){
        TipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tipCell"];
        
        if(cell == nil){
            cell = [TipCell tipCell];
            cell.titleLbl.text = @"Brian B. says:";
            cell.contentLbl.text = @"Awesome City and Country, great people...";
        }
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusable"];
        }
        
        cell.textLabel.text = @"Default cell";
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - LocationDetailViewDelegate

- (void)locationDetail:(TGFoursquareLocationDetail *)locationDetail imagePagerDidLoad:(KIImagePager *)imagePager
{
    imagePager.dataSource = self;
    imagePager.delegate = self;
    imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    imagePager.slideshowTimeInterval = 0.0f;
    imagePager.slideshowShouldCallScrollToDelegate = YES;
    
    self.locationDetail.nbImages = (int)[self.locationDetail.imagePager.dataSource.arrayWithImages count];
    self.locationDetail.currentImage = 0;
}

- (void)locationDetail:(TGFoursquareLocationDetail *)locationDetail tableViewDidLoad:(UITableView *)tableView
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)locationDetail:(TGFoursquareLocationDetail *)locationDetail headerViewDidLoad:(UIView *)headerView
{
    [headerView setAlpha:0.0];
    [headerView setHidden:YES];
}

#pragma mark - KIImagePager DataSource
- (NSArray *) arrayWithImages
{
    return @[
             @"https://irs2.4sqi.net/img/general/500x500/2514_BvEN_Q6lG50xZQ9TIG0XY8eYXzF3USSMdtTmxHCmqnE.jpg",
             @"https://irs3.4sqi.net/img/general/500x500/6555164_Rkk21OJj4X54X8bkutzxbeCwLHTA8Hrre6_wUVc1DMg.jpg",
             @"https://irs2.4sqi.net/img/general/500x500/3648632_NVZOdXiRTkVtzHoGNh5c5SqsF2NxYDB_FMfXRCbYu6I.jpg",
             @"https://irs1.4sqi.net/img/general/500x500/23351702_KoUKj6hZLOTHIsawxi2L64O5CpJwCadeIv2daMBDE8Q.jpg"
             ];
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFill;
}

- (NSString *) captionForImageAtIndex:(NSUInteger)index
{
    return @[
             @"First screenshot",
             @"Another screenshot",
             @"Last one! ;-)"
             ][index];
}

#pragma mark - KIImagePager Delegate
- (void) imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

- (void) imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

#pragma mark - Button actions

- (void)back
{
    NSLog(@"Here you should go back to previous view controller");
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)post
{
    NSLog(@"Post action");
}



@end
