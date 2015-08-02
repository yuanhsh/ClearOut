//
//  ListPhotoCell.m
//  ClearOut
//
//  Created by YUAN on 15/7/25.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "ListPhotoCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ListPhotoCell ()
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@end

@implementation ListPhotoCell

- (void) setItem:(PFObject *)item {
    _item = item;
    NSNumber *price = item[@"price"];
    _priceLabel.text = [NSString stringWithFormat: @"$ %ld", [price integerValue]];
    _locationLabel.text = item[@"address"];
    _itemTitle.text = item[@"title"];
    PFFile *file1 = item[@"owner"][@"profilePicMedium"];
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:[file1 url]]];
//    self.userImage.file = item[@"owner"][@"profilePicMedium"];
//    [self.userImage loadInBackground];
    self.userImage.layer.cornerRadius = self.userImage.frame.size.height/2.0f;
    self.userImage.clipsToBounds = YES;
    PFFile *file2 = item[@"images"][0];
    [_itemImage sd_setImageWithURL:[NSURL URLWithString:[file2 url]]];
//    _itemImage.file = item[@"images"][0];
//    [_itemImage loadInBackground];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
