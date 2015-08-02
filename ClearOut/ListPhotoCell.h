//
//  ListPhotoCell.h
//  ClearOut
//
//  Created by YUAN on 15/7/25.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "PFTableViewCell.h"
#import <Parse/Parse.h>
@interface ListPhotoCell : PFTableViewCell
@property (strong, nonatomic) PFObject *item;

@end
