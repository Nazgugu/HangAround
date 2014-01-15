//
//  NearByPlaceTableViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-12.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "NearByPlaceTableViewController.h"
#import "AFNetworking.h"
#import "Singleton.h"

@interface NearByPlaceTableViewController ()
@property (strong, nonatomic) NSArray *googlePlacesArrayFromAFNetworking;
@property (strong, nonatomic) NSArray *finishedGooglePlacesArray;
@property (nonatomic) double retLat;
@property (nonatomic) double retLon;
@end

@implementation NearByPlaceTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeRestaurantRequests];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeRestaurantRequests
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&sensor=true&location=%f,%f&radius=15000&key=AIzaSyBLlAZH4Ik9m94DRq9kCVtS8InyFpEh7u8",self.typeString,self.latitude,self.longtitude];
    NSLog(@"%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetWorking asynchronous url request
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        self.googlePlacesArrayFromAFNetworking = [responseObject objectForKey:@"results"];
        NSLog(@"The array: %@",self.googlePlacesArrayFromAFNetworking);
        [self.tableView reloadData];
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Request Failed: %@, %@", error, error.userInfo);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.googlePlacesArrayFromAFNetworking count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeCell" forIndexPath:indexPath];
    NSDictionary *tempDictionary = [self.googlePlacesArrayFromAFNetworking objectAtIndex:indexPath.row];
    cell.textLabel.text = [tempDictionary objectForKey:@"name"];
    if ([tempDictionary objectForKey:@"rating"])
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Rating: %@ of 5",[tempDictionary objectForKey:@"rating"]];
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Not Rated"];
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tempDictionary = [self.googlePlacesArrayFromAFNetworking objectAtIndex:indexPath.row];
    NSDictionary *coordinateDict = [[tempDictionary objectForKey:@"geometry"] objectForKey:@"location"];;
    [Singleton globalData].latitude = [[coordinateDict objectForKey:@"lat"] doubleValue];
    [Singleton globalData].longtitude = [[coordinateDict objectForKey:@"lng"] doubleValue];
    [Singleton globalData].locationString = [tempDictionary objectForKey:@"name"];
    [Singleton globalData].addName = [tempDictionary objectForKey:@"formatted_address"];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
