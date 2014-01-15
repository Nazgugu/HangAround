//
//  HomeViewController.m
//  BuddyUp
//
//  Created by Liu Zhe on 14-1-2.
//  Copyright (c) 2014年 CDFLS. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "TGRImageViewController.h"
#import "TGRImageZoomAnimationController.h"
#import "UIImage+Resize.h"
#import "Singleton.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define ORIGINAL_MAX_WIDTH 640.0f

@interface HomeViewController ()<UIViewControllerTransitioningDelegate, VPImageCropperDelegate, UIAlertViewDelegate>
{
    BOOL isFullScreen;
    dispatch_queue_t queue;
}
@end

@implementation HomeViewController
@synthesize UserImage;

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
    UserImage.borderColor = [UIColor whiteColor];
    UserImage.borderWidth = 3.0;
    UserImage.contentMode = UIViewContentModeScaleAspectFill;
    UserImage.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PFUser currentUser]) {
        self.Username.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome, %@", nil), [[PFUser currentUser] username]];
    }
    else {
        self.Username.text = NSLocalizedString(@"Not logged in", nil);
    }
    if (UserImage.image == nil)
    {
        NSLog(@"User image is not set!");
        PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
        PFUser *user = [PFUser currentUser];
        [query whereKey:@"user" equalTo:user];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 //find succeed
                 NSLog(@"succeed");
                 if ([objects count] > 0)
                 {
                     PFObject *imageObject = [objects objectAtIndex:0];
                     PFFile *imageFile = [imageObject objectForKey:@"imageFile"];
                     [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                      {
                          UIImage *image = [UIImage imageWithData:data];
                          [UserImage setImage:image];
                      }];
                 }
                 else
                 {
                     NSLog(@"Error : %@ %@", error, [error userInfo]);
                     dispatch_async(dispatch_get_main_queue(), ^{
                     [UserImage setImage:[UIImage imageNamed:@"default_profile_4"]];
                     });
                 }
             }
         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    [self resizeImage:editedImage];
    //isFullScreen = NO;
    [UserImage setImage:[Singleton globalData].avatar];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue, ^{
            [self uploadImage];
            isFullScreen = NO;
        });
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	
    [picker dismissViewControllerAnimated:YES completion:^()
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        image = [self imageByScalingToMaxSize:image];
        VPImageCropperViewController *ImgEditorVC = [[VPImageCropperViewController alloc] initWithImage:image cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.height - 250.0f) limitScaleRatio:2.5];
        ImgEditorVC.delegate = self;
        [self presentViewController:ImgEditorVC animated:YES completion:^{
            ImgEditorVC.hidesBottomBarWhenPushed = YES;
            isFullScreen = YES;
        }];
    }];
    
}

- (void)resizeImage:(UIImage *)image
{
    CGFloat height = 480.0f;
    CGFloat width = (height / image.size.height) * image.size.width;
    UIImage *newImage = [image resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationDefault];
    [Singleton globalData].avatar = newImage;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)uploadImage
{
    //get image from sandbox
    UIImage *savedImage = [Singleton globalData].avatar;
    NSData *imageData = UIImagePNGRepresentation(savedImage);
    //upload to database
    NSString *userImageFileName = [NSString stringWithFormat:@"%@_UserProfile.jpeg",[[PFUser currentUser] username]];
    PFFile *imageFile = [PFFile fileWithName:userImageFileName data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error)
        {
            PFUser *user = [PFUser currentUser];
            PFQuery *photoQuery = [PFQuery queryWithClassName:@"UserPhoto"];
            [photoQuery whereKey:@"user" equalTo:user];
            [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
               if (!error)
               {
                   if ([objects count] > 0)
                   {
                       //if exist photo update it
                       PFObject *tempObj = [objects lastObject];
                       [photoQuery getObjectInBackgroundWithId:tempObj.objectId block:^(PFObject *object, NSError *error){
                           if (!error){
                               object[@"imageFile"] = imageFile;
                               [object saveInBackground];
                               UIAlertView *imageUpdate = [[UIAlertView alloc] initWithTitle:@"Grats" message:@"Successfully updated your avatar" delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
                               [imageUpdate show];
                               NSLog(@"Can you see me?");
                           }
                       }];
                   }
                   else
                   {
                       //if not then upload the first one
                       PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
                       [userPhoto setObject:imageFile forKey:@"imageFile"];
                       [userPhoto setObject:user forKey:@"user"];
                       [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                          if (!error)
                          {
                              //upload succeed
                              UIAlertView *firstTimeUpLoad = [[UIAlertView alloc] initWithTitle:@"Grats" message:@"Successfully uploaded first photo" delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
                              [firstTimeUpLoad show];
                          }
                           else
                           {
                               NSLog(@"uploading error: %@, %@", error, [error userInfo]);
                           }
                       }];
                   }
               }
                else
                {
                    NSLog(@": %@ %@", error, [error userInfo]);
                }
            }];
            
        }
        else
        {
            NSLog(@"so damn: %@ %@", error, [error userInfo]);
        }
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)choosePhotoFromCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.allowsEditing = YES;
    controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    controller.delegate = self;
    [self presentViewController: controller animated: YES completion: nil];

}

- (void)choosePhotoFromLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = YES;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self presentViewController: controller animated: YES completion: nil];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)Logout:(id)sender {
    [PFUser logOut];
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"LogoutUser" sender:self];

}

#pragma transitions

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:UserImage];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:TGRImageViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:UserImage];
    }
    return nil;
}

- (void)showImage {
    TGRImageViewController *viewController = [[TGRImageViewController alloc] initWithImage:UserImage.image];
    viewController.transitioningDelegate = self;
    
    [self presentViewController:viewController animated:YES completion:nil];
}


#pragma actionsheets

- (IBAction)showAvatar:(UITapGestureRecognizer*)sender {
    UIActionSheet *selectImage = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Image", @"Select Image", nil];
    [selectImage showInView:self.view];
        selectImage.tag = 1;
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        if (buttonIndex == 0)
        {
            [self showImage];
        }
        if (buttonIndex == 1)
        {
            UIActionSheet *chooseFrom;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                chooseFrom = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Camara", @"Choose from library", nil];
            }
            else
            {
                chooseFrom = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose from library", nil];
            }
            chooseFrom.tag = 2;
            [chooseFrom showInView:self.view];
        }
    }
    if (actionSheet.tag == 2)
    {
            //0 is camera, 1 is library,2 is cancel
        if (buttonIndex == 0)
        {
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];

        }
        }
        else if (buttonIndex == 1)
        {
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];

        }
        }
    }
}
        
#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}



@end
