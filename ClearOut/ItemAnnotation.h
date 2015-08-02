//
//  ItemAnnotation.h
//  ClearOut
//
//  Created by YUAN on 15/8/2.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface ItemAnnotation : MKPointAnnotation <MKAnnotation>
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
//@property (nonatomic, readonly, copy) NSString *title;
//@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, strong) PFObject *item;
- (id) initWithPFItem:(PFObject *)item;
- (MKAnnotationView *)annotationView;
@end
