//
//  PublishViewController.m
//  ClearOut
//
//  Created by YUAN on 15/8/1.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "PublishViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIImage+ResizeAdditions.h"
#import <UIImage+ResizeMagick.h>
#import <Parse/Parse.h>
#import <GBFlatButton/GBFlatButton.h>

@interface PublishViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UITextField *location;
@property (weak, nonatomic) IBOutlet UITextView *itemDesc;
@property (weak, nonatomic) IBOutlet GBFlatButton *addPhotoBtn;
@property (weak, nonatomic) IBOutlet GBFlatButton *publishBtn;
@property (strong, nonatomic) UIImage *imageCache;
@property (strong, nonatomic) CLLocationManager *locman;
@property (strong, nonatomic) CLLocation *currentLoc;
@end

@implementation PublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Publish Your Item";
    self.addPhotoBtn.layer.cornerRadius = 5;
    self.publishBtn.layer.cornerRadius = 5;
    [_itemDesc.layer setBorderColor: [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [_itemDesc.layer setBorderWidth: 1.0];
    [_itemDesc.layer setCornerRadius:5.0f];
    [_itemDesc.layer setMasksToBounds:YES];
    _locman = [[CLLocationManager alloc] init];
    _locman.delegate = self;
    [_locman requestWhenInUseAuthorization];
    [_locman startUpdatingLocation];
}
- (IBAction)addPhoto:(id)sender {
    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
    camera.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [camera setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    [self presentViewController:camera animated:YES completion:nil];
}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPublish:(id)sender {
    [SVProgressHUD show];
    PFObject *item = [PFObject objectWithClassName:@"Item"];
    item[@"title"] = self.titleText.text;
    item[@"description"] = self.itemDesc.text;
    item[@"address"] = self.location.text;
    item[@"location"] = [PFGeoPoint geoPointWithLocation:self.currentLoc];
    item[@"images"] = @[[PFFile fileWithData:UIImageJPEGRepresentation(_imageCache, 1.0f)]];
    item[@"owner"] = [PFUser currentUser];
    item[@"price"] = [NSNumber numberWithInt:[self.price.text intValue]];
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error){
        [SVProgressHUD dismiss];
        if(succeeded) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"Error when saving item!");
        }
    }];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    self.addPhotoBtn.hidden = YES;
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *tmpImage = (UIImage *) info[UIImagePickerControllerOriginalImage];
        _imageCache = [tmpImage resizedImageByMagick: @"1500x1200#"];
        _photo.image = _imageCache;
            }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLoc = [locations lastObject];
    __weak PublishViewController *weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:_currentLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error || ![placemarks count]) {
            NSLog(@"%@", @"Geocoder error!");
            return;
        }
        CLPlacemark *placemark = [placemarks lastObject];
        NSString *currentAddr = [NSString stringWithFormat:@"%@, %@, %@, %@", placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
        weakSelf.location.text = currentAddr;
    }];
    [manager stopUpdatingLocation];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder && [nextResponder isKindOfClass:[UITextField class]]) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        if ([nextResponder isKindOfClass:[UIButton class]]) {
            
        }
    }
    return NO; // We do not want UITextField to insert line-breaks.
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
