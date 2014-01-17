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

@property (strong, nonatomic) IBOutlet MKMapView *myMap;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailPost;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *time;
- (IBAction)chatButton:(id)sender;
@end

@implementation DetailPostViewController

@synthesize addressLabel, myMap, typeLabel, detailPost, userName,time;

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
    [detailPost setText:self.postText];
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
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.latitude, self.longtitude), 5000, 5000);
    [myMap setRegion:region animated:YES];
    [myMap setShowsUserLocation:YES];
    [time setText:self.actTime];
    // Do any additional setup after loading the view.
    //annotation
    CDAnnotation *annotation;
    if (![self.storeName isEqualToString:@""])
    {
        NSLog(@"I got a name %@",self.storeName);
        annotation = [[CDAnnotation alloc] initWithTitle:self.storeName Location:CLLocationCoordinate2DMake(self.latitude, self.longtitude)];
    }
    else
    {
        NSLog(@"I do not have a name!");
        annotation = [[CDAnnotation alloc] initWithTitle:@"Location" Location:CLLocationCoordinate2DMake(self.latitude, self.longtitude)];
    }
    [myMap addAnnotation:annotation];
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
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"storePin"];
        if (!annotationView)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"storePin"];
            annotationView.canShowCallout = YES;
            //annotationView.enabled = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
            imageView.image = self.storeImage;
            annotationView.leftCalloutAccessoryView = imageView;
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


- (IBAction)chatButton:(id)sender {
}
@end
