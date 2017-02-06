//
//  uploadCoordinates.h
//  ActiveAging_v1.0
//
//  Created by potyer on 2017/1/28.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface uploadCoordinates : NSObject <MKMapViewDelegate,CLLocationManagerDelegate>

{
    double currentLat;
    double currentLon;
    NSString *lat;
    NSString *lon;
    CLLocationManager * locationManager;
}

+ (instancetype) sharedInstance;

- (void) reportTheSite:(NSString*)URL;

@end
