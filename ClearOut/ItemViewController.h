//
//  ItemViewController.h
//  ClearOut
//
//  Created by YUAN on 15/8/2.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface ItemViewController : UITableViewController
@property (strong, nonatomic) PFObject *item;
@end
