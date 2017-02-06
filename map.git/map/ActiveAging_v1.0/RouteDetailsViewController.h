//
//  RouteDetailsViewController.h
//  ActiveAging_v1.0
//
//  Created by potyer on 2017/1/30.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteDetailsTableViewCell.h"

@interface RouteDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSString *roadWays;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (strong, nonatomic) RouteDetailsTableViewCell *routeCell;

@end
