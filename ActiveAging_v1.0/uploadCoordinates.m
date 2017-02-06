//
//  uploadCoordinates.m
//  ActiveAging_v1.0
//
//  Created by potyer on 2017/1/28.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "uploadCoordinates.h"

#define USER_NAME @"Sean"
@implementation uploadCoordinates


+(instancetype)sharedInstance{
    
    uploadCoordinates *uploadLocations;
    if (uploadLocations == nil) {
        uploadLocations = [uploadCoordinates new];
    }
    return uploadLocations;
}

-(void)reportTheSite:(NSString *)URL{
    
    // HTTP POST sample code
    
    currentLat = locationManager.location.coordinate.latitude;
    currentLon = locationManager.location.coordinate.longitude;
    
    lat = [NSString stringWithFormat:@"%lf", currentLat];
    lon = [NSString stringWithFormat:@"%lf", currentLon];
    
    
    NSString *DataString = [NSString stringWithFormat:@"user=%@&lat=%@&lon=%@", USER_NAME, lat, lon];
    
    // To Set Up the SERVER connection
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURL *url = [NSURL URLWithString:URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Transfer the DATA to NSData and put it into .HTTPBody
    request.HTTPBody = [DataString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    // To set up the block for NSURLSessionDataTask
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", error);
        }
        
        // To handle the response DATA here
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];  // for debug
        NSLog(@"%@",jsonString);
        
    }];
    
    // Start processing connection
    [postDataTask resume];

}

@end
