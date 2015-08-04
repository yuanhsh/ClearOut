//
//  BeforePost.m
//  ClearOut
//
//  Created by helen on 8/4/15.
//  Copyright (c) 2015 Yuan Haisheng. All rights reserved.
//

#import "BeforePost.h"

#import "ItemViewController.h"

@interface BeforePost ()
@end

@implementation BeforePost

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textArea.delegate = self;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tweet:(id)sender {
    ACAccountStore *twitter = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [twitter accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [twitter requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accountList = [twitter accountsWithAccountType:accountType];
            
            if ([accountList count] > 0) {
                ACAccount *twitterAccount = [accountList objectAtIndex:0];
                
                if (_type==FALSE) {
                    
                    NSData *imageData = UIImageJPEGRepresentation(self.imgTmp, 0.9);
                    [self uploadImage:imageData account:twitterAccount withCompletion:nil];
                    
                    _information = [[NSString alloc] initWithFormat: @"%@ - Share from ClearOut. %@ only $%@: %@",self.textArea.text, self.item[@"title"], self.item[@"price"], self.item[@"description"]];
                    
                    NSLog(@"%@", _information);
                    
                    
                } else {
                    NSLog(@"No image.");
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                NSLog(@"Cannot find the Twitter Account.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erorr"
                                                                message:@"Please add a Twitter Account in the setting"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } else {
            NSLog(@"Cannot find the Twitter Account.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erorr"
                                                            message:@"Please add a Twitter Account in the setting."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}


- (BOOL)textView:(UITextView *)text
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)textStr {
    if ([textStr isEqualToString:@"\n"]) {
        [text resignFirstResponder];
    }
    return YES;
}

-(void)uploadImage:(NSData*)imageData account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:nil];
    postRequest.account = account;
    [postRequest addMultipartData:imageData withName:@"media" type:@"image/jpeg" filename:@"photo"];
    
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        NSLog(@"Status Code: %ld", (long)[urlResponse statusCode]);
        if (error) {
            NSLog(@"Error:%@", [error localizedDescription]);
        } else {
            NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            NSString *mediaID = [NSString stringWithFormat:@"%@", [returnedData valueForKey:@"media_id_string"]];
            [self postTweetWithMedia:imageData mediaID:mediaID account:account withCompletion:completion];
        }
    }];
}

-(void)uploadVideo:(NSData*)videoData account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    NSDictionary *postParams = @{@"command": @"INIT",
                                 @"total_bytes" : [NSNumber numberWithInteger: videoData.length].stringValue,
                                 @"media_type" : @"video/mp4"
                                 };
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    request.account = account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Status Code: %ld", (long)[urlResponse statusCode]);
        if (error) {
            NSLog(@"Error:%@", [error localizedDescription]);
        } else {
            NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            NSString *mediaID = [NSString stringWithFormat:@"%@", [returnedData valueForKey:@"media_id_string"]];
            [self tweetVideoStage2:videoData mediaID:mediaID account:account withCompletion:completion];
        }
    }];
}

-(void)tweetVideoStage2:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    NSDictionary *postParams = @{@"command": @"APPEND",
                                 @"media_id" : mediaID,
                                 @"segment_index" : @"0",
                                 };
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    postRequest.account = account;
    [postRequest addMultipartData:videoData withName:@"media" type:@"video/mp4" filename:@"video"];
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Status Code: %ld", (long)[urlResponse statusCode]);
        if (!error) {
            [self tweetVideoStage3:videoData mediaID:mediaID account:account withCompletion:completion];
        }
    }];
}

-(void)tweetVideoStage3:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    NSDictionary *postParams = @{@"command": @"FINALIZE",  @"media_id" : mediaID };
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    
    // Set the account and begin the request.
    postRequest.account = account;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Status Code: %ld", (long)[urlResponse statusCode]);
        if (!error) {
            [self postTweetWithMedia:videoData mediaID:mediaID account:account withCompletion:completion];
        }
    }];
}

-(void)postTweetWithMedia:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    
    // Set the parameters for the third twitter video request.
    NSDictionary *postParams = @{@"status": _information, @"media_ids" : @[mediaID]};
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    postRequest.account = account;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Status Code: %ld", (long)[urlResponse statusCode]);
        if (!error) {
            NSLog(@"Success");
        }
    }];
    
}

@end
