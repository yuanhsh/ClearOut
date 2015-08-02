//
//  MapViewController.m
//  ClearOut
//
//  Created by YUAN on 15/7/24.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface MapViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (strong, nonatomic) NSArray *items;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.005, 0.005));
        [_mapview setRegion:region animated:YES];
        PFQuery *query = [PFQuery queryWithClassName:@"Item"];
        [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:5];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            _items = objects;
            NSMutableArray *annotations = [NSMutableArray array];
            for (PFObject *item in objects) {
                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                PFGeoPoint *location = item[@"location"];
                point.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                NSNumber *price = item[@"price"];
                point.title = [NSString stringWithFormat: @"$ %ld", [price integerValue]];
                point.subtitle = item[@"title"];
                [annotations addObject:point];
            }
            [_mapview showAnnotations:annotations animated:YES];
        }];
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.title = @"NearBy";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
