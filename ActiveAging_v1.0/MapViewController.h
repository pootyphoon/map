//
//  MapViewController.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/24/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uploadCoordinates.h"

@interface MapViewController : UIViewController

@property (strong, nonatomic) MKRoute * route;

@property (strong, nonatomic) MKRouteStep * step;

@property (strong, nonatomic) MKDirectionsResponse * routeResponse;

@property (strong, nonatomic) NSString * routeInformation;

+ (instancetype) sharedInstance;

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)showRoute:(MKDirectionsResponse *)response;

@end
