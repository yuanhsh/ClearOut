//
//  BeforePost.h
//  ClearOut
//
//  Created by helen on 8/4/15.
//  Copyright (c) 2015 Yuan Haisheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
@interface BeforePost :  UIViewController<UITextViewDelegate>
//@property (strong, nonatomic) NSURL *videoURL;
@property (nonatomic,assign) BOOL type;
@property (strong, nonatomic) UIImage *imgTmp;
@property (strong, nonatomic) NSString *information;
@property (strong, nonatomic) NSString *message;

@property (strong, nonatomic) PFObject *item;
@property (weak, nonatomic) IBOutlet UITextView *textArea;

@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *tweet;
- (IBAction)cancel:(id)sender;
- (IBAction)tweet:(id)sender;

@end