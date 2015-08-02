//
//  ItemAnnotation.m
//  ClearOut
//
//  Created by YUAN on 15/8/2.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "ItemAnnotation.h"

@implementation ItemAnnotation 

- (id) initWithPFItem:(PFObject *)item {
    self = [super init];
    if (self) {
        _item = item;
        NSNumber *price = item[@"price"];
        self.title = [NSString stringWithFormat: @"$ %ld", [price integerValue]];
        self.subtitle = item[@"title"];
        PFGeoPoint *location = item[@"location"];
        self.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    }
    return self;
}
- (MKAnnotationView *)annotationView {
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"ItemAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.pinColor = MKPinAnnotationColorRed;
//    annotationView.image = [UIImage imageNamed:@"first"];
    UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = disclosure;
    return annotationView;
}

@end
