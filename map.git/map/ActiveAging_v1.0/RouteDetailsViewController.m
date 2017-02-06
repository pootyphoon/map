//
//  RouteDetailsViewController.m
//  ActiveAging_v1.0
//
//  Created by potyer on 2017/1/30.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "RouteDetailsViewController.h"
#import "MapViewController.h"

@interface RouteDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) MapViewController *mapviewVC;

@end

@implementation RouteDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _resultArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = _resultArray[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    return cell;
}




@end
