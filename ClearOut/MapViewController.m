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
#import "ItemAnnotation.h"
#import "ItemViewController.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (strong, nonatomic) NSArray *items;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapview.delegate = self;
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.005, 0.005));
        [_mapview setRegion:region animated:YES];
        PFQuery *query = [PFQuery queryWithClassName:@"Item"];
        [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:5];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            _items = objects;
            NSMutableArray *annotations = [NSMutableArray array];
            for (PFObject *item in objects) {
                ItemAnnotation *point = [[ItemAnnotation alloc] initWithPFItem:item];
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[ItemAnnotation class]]) {
        ItemAnnotation *itemAnnotation = (ItemAnnotation *)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"ItemAnnotation"];
        if (annotationView == nil) {
            annotationView = itemAnnotation.annotationView;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    } else
         return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[ItemAnnotation class]]) {
        ItemAnnotation *itemAnnotation = (ItemAnnotation *)view.annotation;
        ItemViewController *itemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
        itemVC.item = itemAnnotation.item;
        [self.navigationController pushViewController:itemVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
