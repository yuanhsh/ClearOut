//
//  ItemViewController.m
//  ClearOut
//
//  Created by YUAN on 15/8/2.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "ItemViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MapKit/MapKit.h>

@interface ItemViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet PFImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
@property (weak, nonatomic) IBOutlet UITextView *itemDesc;
@property (strong, nonatomic) MKPointAnnotation *annotation;
@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title = self.item[@"title"];
    NSNumber *price = _item[@"price"];
    _priceLabel.text = [NSString stringWithFormat: @"$ %d", [price integerValue]];
    _adressLabel.text = _item[@"address"];
    _itemTitle.text = _item[@"title"];
    self.avatar.file = _item[@"owner"][@"profilePicMedium"];
    [self.avatar loadInBackground];
    self.avatar.layer.cornerRadius = self.avatar.frame.size.height/2.0f;
    self.avatar.clipsToBounds = YES;
    self.photoView.file = _item[@"images"][0];
    [self.photoView loadInBackground];
    self.itemDesc.text = _item[@"description"];
    PFGeoPoint *point = _item[@"location"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate , MKCoordinateSpanMake(0.001, 0.001));
    [_mapview setRegion:region animated:YES];
    _annotation = [[MKPointAnnotation alloc] init];
    [_mapview addAnnotation:_annotation];
    _annotation.coordinate = coordinate;
    _annotation.title = _item[@"address"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
