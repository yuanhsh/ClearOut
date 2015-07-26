//
//  ListViewController.m
//  ClearOut
//
//  Created by YUAN on 15/7/24.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "ListViewController.h"
#import <ParseUI/PFImageView.h>

@interface ListViewController ()


@end

@implementation ListViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Item";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
