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

@interface HomeViewController ()<UIViewControllerTransitioningDelegate>
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

#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1.0);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}

#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat height = 480.0f;
        CGFloat width = (height / image.size.height) * image.size.width;
        UIImage *newImage = [image resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationDefault];
        [self saveImage:newImage withName:@"currentImage.png"];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    
            //UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
            isFullScreen = NO;
            [UserImage setImage:newImage];
        });
    
    });
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self uploadImage];
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadImage
{
    //get image from sandbox
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
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
        // check if support camara
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 2:
                    // cancel
                    return;
                case 0:
                    // camara
                    [self choosePhotoFromCamera];
                    break;
                    
                case 1:
                    // library
                    [self choosePhotoFromLibrary];
                    break;
            }
        }
    }
}



@end
