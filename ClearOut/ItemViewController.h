//
//  ItemViewController.h
//  ClearOut
//
//  Created by YUAN on 15/8/2.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface ItemViewController : UITableViewController
@property (strong, nonatomic) PFObject *item;

@property (weak, nonatomic) IBOutlet UIButton *tweet;
- (IBAction)tweet:(id)sender;

@end
