//
//  PostViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-4.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

//static double const kPAWFeetToMeters = 0.3048; // this is an exact value.
//static double const kPAWFeetToMiles = 5280.0; // this is an exact value.
//static double const kPAWWallPostMaximumSearchDistance = 100.0;
//static double const kPAWMetersInAKilometer = 1000.0; // this is an exact value.



#import "PostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HMSegmentedControl.h"
#import <Parse/Parse.h>
#import "CDAppDelegate.h"
#import "NearByPlaceTableViewController.h"

@interface PostViewController ()<RMDateSelectionViewControllerDelegate, CLLocationManagerDelegate>
{
    dispatch_queue_t queue;
    CLLocationManager *locationManager;
}
- (void)updateCharacterCount:(UITextView *)aTextView;
- (BOOL)checkCharacterCount:(UITextView *)aTextView;
- (void)textInputChanged:(NSNotification *)note;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) double latitude;
@property (nonatomic) double longtitude;
@property (strong, nonatomic) HMSegmentedControl *typeSelection;
@property (strong, nonatomic) RMDateSelectionViewController *datePickController;
@end

@implementation PostViewController
@synthesize textView;
@synthesize characterCount;
@synthesize dateSelection;
@synthesize keyBoardAvoidingScrollView;
@synthesize locationText;
@synthesize typeSelection;

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
    // Do any additional setup after loading the view.
    //right bar button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post!" style:UIBarButtonItemStyleBordered target:self action:@selector(postToServer)];
    
    //Setup boarder for textview
    textView.layer.borderWidth = 1;
    [textView.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [textView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [textView.layer setBorderWidth:1.0];
    [textView.layer setCornerRadius:8.0f];
    [textView.layer setMasksToBounds:YES];
    
    //setup text count;
    self.characterCount = [[UILabel alloc] initWithFrame:CGRectMake(240.0f, 120.0f, 75.0f, 25.0f)];
    self.characterCount.backgroundColor = [UIColor clearColor];
    self.characterCount.textColor = [UIColor lightGrayColor];
    self.characterCount.shadowColor = [UIColor  colorWithWhite:0.0f alpha:0.7f];
    self.characterCount.shadowOffset = CGSizeMake(0.0f, -1.0f);
    self.characterCount.text = @"0/60";
    //[self.textView setInputAccessoryView:self.characterCount];
    [textView addSubview:self.characterCount];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextViewTextDidChangeNotification object:textView];
    [self updateCharacterCount:textView];
    [self checkCharacterCount:textView];
    
    //keyboard tool bar
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyboard)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:space, done, nil]];
    [textView setInputAccessoryView:toolbar];
    // Show the keyboard/accept input.
	//[textView becomeFirstResponder];
    
    //segmented control for  type selection
    typeSelection = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Entertainment", @"Sports", @"Shopping", @"Meal"]];
    [typeSelection setSelectionIndicatorHeight:4.0f];
    [typeSelection setBackgroundColor:[UIColor colorWithRed:0.1 green:0.4 blue:0.8 alpha:1]];
    [typeSelection setTextColor:[UIColor whiteColor]];
    [typeSelection setSelectedTextColor:[UIColor whiteColor]];
    [typeSelection setSelectionIndicatorColor:[UIColor colorWithRed:0.5 green:0.8 blue:1 alpha:1]];
    [typeSelection setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [typeSelection setSelectedSegmentIndex:HMSegmentedControlNoSegment];
    [typeSelection setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationDown];
    typeSelection.scrollEnabled = YES;
    typeSelection.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [typeSelection setFrame:CGRectMake(17, 230, 286, 40)];
    [typeSelection addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [keyBoardAvoidingScrollView addSubview:typeSelection];
    
    //locationText clear button
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"clearButton.png"] forState:UIControlStateNormal];
    [clearButton setFrame:CGRectMake(-15, 0, 20, 20)];
    [clearButton addTarget:self action:@selector(clearTextField) forControlEvents:UIControlEventTouchUpInside];
    locationText.rightViewMode = UITextFieldViewModeNever;
    [locationText setRightView:clearButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 50.0f;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];
}

#pragma segmentedControl
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
	NSLog(@"Selected index %li (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
	NSLog(@"Selected index %li", (long)segmentedControl.selectedSegmentIndex);
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)hideKeyboard
{
    [[self textView] resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextView notification methods

- (void)textInputChanged:(NSNotification *)note {
	// Listen to the current text field and count characters.
	UITextView *localTextView = [note object];
	[self updateCharacterCount:localTextView];
	[self checkCharacterCount:localTextView];
}

#pragma mark Private helper methods

- (void)updateCharacterCount:(UITextView *)aTextView {
	NSUInteger count = aTextView.text.length;
	self.characterCount.text = [NSString stringWithFormat:@"%lu/60", (unsigned long)count];
	if (count > kPAWWallPostMaximumCharacterCount || count == 0) {
		self.characterCount.font = [UIFont boldSystemFontOfSize:self.characterCount.font.pointSize];
	} else {
		self.characterCount.font = [UIFont systemFontOfSize:self.characterCount.font.pointSize];
	}
}

- (BOOL)checkCharacterCount:(UITextView *)aTextView {
	NSUInteger count = aTextView.text.length;
	if (count > kPAWWallPostMaximumCharacterCount || count == 0) {
		//postButton.enabled = NO;
		return NO;
	} else {
		//postButton.enabled = YES;
		return YES;
	}
}

//Date Picker
- (void)openDateSelectionController
{
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    dateSelectionVC.delegate = self;
    
    //You can enable or disable bouncing and motion effects
    //dateSelectionVC.disableBouncingWhenShowing = YES;
    //dateSelectionVC.disableMotionEffects = YES;
    
    [dateSelectionVC show];
    
    //After -[RMDateSelectionViewController show] or -[RMDateSelectionViewController showFromViewController:] has been called you can access the actual UIDatePicker via the datePicker property
    dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    dateSelectionVC.datePicker.minuteInterval = 1;
    dateSelectionVC.datePicker.date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
    //You can also adjust colors (enabling example will result in a black version)
    //dateSelectionVC.tintColor = [UIColor whiteColor];
    //dateSelectionVC.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
}

#pragma mark - RMDAteSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate {
    keyBoardAvoidingScrollView.contentOffset = CGPointMake(0, -40);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSString *formattedDate = [formatter stringFromDate:aDate];
    NSLog(@"////");
    self.dateSelection.text = formattedDate;
    NSLog(@"Successfully selected date: %@", aDate);
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    keyBoardAvoidingScrollView.contentOffset = CGPointMake(0, -40);
    NSLog(@"Date selection was canceled");
}

//textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == dateSelection)
    {
        [textField resignFirstResponder];
        // Show you custom picker here....
        [self openDateSelectionController];
        [textView resignFirstResponder];
        keyBoardAvoidingScrollView.contentOffset = CGPointMake(0, 60);
        return NO;
    }
    else if (textField == locationText)
    {
        if ([textField.text isEqualToString:@""])
        {
            textField.rightViewMode = UITextFieldViewModeAlways;
            [textField resignFirstResponder];
            [self updateLocation];
            return NO;
        }
        else
         {
             NSLog(@"Nothing");
             [self performSegueWithIdentifier:@"selectLocation" sender:self];
             return NO;
        }
    }
    return YES;
}

- (void)clearTextField
{
    [locationText resignFirstResponder];
    locationText.text = @"";
    locationText.rightViewMode = UITextFieldViewModeNever;
    [locationManager stopUpdatingLocation];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.text = @"";
    return YES;
}

- (void)updateLocation
{
    locationText.placeholder = @"Updating Location";
    [locationManager startUpdatingLocation];
    locationText.placeholder = @"Show Location";
}

#pragma locationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@",error);
    locationText.text = @"Fail to get location";
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Location: %@",[locations lastObject]);
    CLLocation *currentLocation = [locations lastObject];
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
    if (currentLocation)
    {
        locationText.text = [NSString stringWithFormat:@"Lat: %.3f, Lon: %.3f",currentCoordinate.latitude,currentCoordinate.longitude];
        self.latitude = currentCoordinate.latitude;
        self.longtitude = currentCoordinate.longitude;
    }
    [locationManager stopUpdatingLocation];
}

#pragma postToServer
- (void)postToServer
{
    //check textfield
    [self updateCharacterCount:textView];
    BOOL isAcceptableAfterAutocorrect = [self checkCharacterCount:textView];
    if (!isAcceptableAfterAutocorrect)
    {
        [textView becomeFirstResponder];
        return;
    }
    
    //prepare data
    
    PFUser *user = [PFUser currentUser];
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:self.latitude longitude:self.longtitude];
    //wrap up all the posting components into a postObject and send this async to Parse
    PFObject *postObject = [PFObject objectWithClassName:kPAWParsePostsClassKey];
    [postObject setObject:textView.text forKey:kPAWParseTextKey];
    [postObject setObject:[NSString stringWithFormat:@"%ld", (long)typeSelection.selectedSegmentIndex] forKey:kPawParseTypeKey];
    [postObject setObject:dateSelection.text forKey:kPawParseTimeKey];
    [postObject setObject:user forKey:kPAWParseUserKey];
    [postObject setObject:currentPoint forKey:kPAWParseLocationKey];
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
       if (error)
       {
           NSLog(@"Could't save!");
           NSLog(@"%@",error);
           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
           [alertView show];
           return;
       }
        if (succeeded)
        {
            NSLog(@"Successfully saved");
            NSLog(@"%@",postObject);
            dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:kPAWPostCreatedNotification object:nil];
			});
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"selectLocation"])
    {
        NearByPlaceTableViewController *placeVC = segue.destinationViewController;
        placeVC.latitude = self.latitude;
        placeVC.longtitude = self.longtitude;
    }
}


@end
