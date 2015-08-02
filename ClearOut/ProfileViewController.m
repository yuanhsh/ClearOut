//
//  ProfileViewController.m
//  ClearOut
//
//  Created by YUAN on 15/7/25.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "ProfileViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "UIImage+ResizeAdditions.h"
#import "AppDelegate.h"
#import <GBFlatButton/GBFlatButton.h>
#import <GBFlatButton/UIColor+GBFlatButton.h>

@interface ProfileViewController () <PFLogInViewControllerDelegate, NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *avatar;
@property (strong, nonatomic) NSMutableData *profilePicData;
@property (weak, nonatomic) IBOutlet UILabel *displayName;
@property (weak, nonatomic) IBOutlet GBFlatButton *publishBtn;
@property (weak, nonatomic) IBOutlet GBFlatButton *logoutBtn;
@end

@implementation ProfileViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser]) {// Check if user is cached
        //![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        
        PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
        logInController.fields = (PFLogInFieldsUsernameAndPassword
                                  | PFLogInFieldsLogInButton
                                  | PFLogInFieldsSignUpButton
                                  | PFLogInFieldsPasswordForgotten
//                                  | PFLogInFieldsDismissButton
                                  | PFLogInFieldsFacebook
                                  | PFLogInFieldsTwitter);
        logInController.delegate = self;
        [logInController setEmailAsUsername:YES];
        [self presentViewController:logInController animated:YES completion:nil];
    } else {
        self.displayName.text = [PFUser currentUser][@"displayName"];
        self.avatar.file = [PFUser currentUser][kProfilePicMedium];
        [self.avatar loadInBackground];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.publishBtn.layer.cornerRadius = 5;
    self.logoutBtn.layer.cornerRadius = 5;
    self.logoutBtn.tintColor = [UIColor gb_pinkColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFLogInViewControllerDelegate
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [logInController dismissViewControllerAnimated:YES completion:nil];
    PFUser *pfuser = [PFUser currentUser];
    NSString *facebookId = [pfuser objectForKey:@"facebookId"];
    if (!facebookId || ![facebookId length]) {
        // set the parse user's FBID
//        [pfuser setObject:[FBSDKAccessToken currentAccessToken].userID forKey:@"facebookId"];
//        [pfuser saveInBackground];
    }
    FBSDKGraphRequestConnection *connection = [FBSDKGraphRequestConnection new];
    
    // profile pic request // picture.type(large),
    FBSDKGraphRequest *profileReq = [[FBSDKGraphRequest alloc] initWithGraphPath: @"me"
                                                              parameters: @{@"fields": @"id, name, first_name, last_name,  email, picture.width(500).height(500)"}
                                                              HTTPMethod: @"GET"];
    [connection addRequest:profileReq completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            pfuser[@"displayName"] = userData[@"name"];
//            pfuser[@"email"] = userData[@"email"];
            pfuser[@"facebookId"] = userData[@"id"];
            
            self.displayName.text = userData[@"name"];
            NSURL *profilePictureURL = [NSURL URLWithString: userData[@"picture"][@"data"][@"url"]];
            
            // Now add the data to the UI elements
            NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
            [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
        } else {
            NSLog(@"Error getting profile pic url, setting as default avatar: %@", error);
            NSData *profilePictureData = UIImagePNGRepresentation([UIImage imageNamed:@"AvatarPlaceholder.png"]);
            [self processFacebookProfilePictureData:profilePictureData];
        }
        [self processedFacebookResponse];
    }];
    
    [connection start];
}

- (void)logInViewController:(PFLogInViewController *)logInController
    didFailToLogInWithError:(PFUI_NULLABLE NSError *)error {
    
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    
}

- (void)processedFacebookResponse {
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Failed save in background of user, %@", error);
        } else {
            NSLog(@"saved current parse user");
            
        }
    }];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _profilePicData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_profilePicData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self processFacebookProfilePictureData:_profilePicData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error downloading profile pic data: %@", error);
}

- (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    NSLog(@"Processing profile picture of size: %@", @(newProfilePictureData.length));
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *mediumImage = [image thumbnailImage:300 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.8); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        _avatar.file = fileMediumImage;
        [_avatar loadInBackground];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kProfilePicMedium];
                [self processedFacebookResponse];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kProfilePicSmall];
                [self processedFacebookResponse];
            }
        }];
    }
    NSLog(@"Processed profile picture");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
