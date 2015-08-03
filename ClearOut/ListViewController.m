//
//  ListViewController.m
//  ClearOut
//
//  Created by YUAN on 15/7/24.
//  Copyright (c) 2015年 Yuan Haisheng. All rights reserved.
//

#import "ListViewController.h"
#import <ParseUI/PFImageView.h>
#import "ListPhotoCell.h"
#import "ItemViewController.h"
@interface ListViewController ()


@end

@implementation ListViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = @"Item";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.title = @"ClearOut";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [super queryForTable];
    [query includeKey:@"owner"];
    return query;
}

#pragma PFTableDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    ListPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPhotoCell"];
    cell.item = object;
    NSLog(@"%@.", object[@"title"]);
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ItemViewController *controller = [segue destinationViewController];
    ListPhotoCell *cell = (ListPhotoCell*)sender;
    controller.item = cell.item;
}
//- (PFUI_NULLABLE PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

@end
