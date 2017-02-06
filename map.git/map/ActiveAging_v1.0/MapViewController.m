//
//  MapViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/24/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "MapViewController.h"
#import "ServerManager.h"
#import "SQLite3DBManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "RouteDetailsViewController.h"
#import "GroupsTableViewCell.h"
#import "RouteDetailsTableViewCell.h"

#define GROUP1 @[@{USER_ID_KEY:@"100",USER_NAME_KEY:@"AlbertLEE",USER_CUR_LAT:@"24.989206",USER_CUR_LON:@"121.313545"},@{USER_ID_KEY:@"101",USER_NAME_KEY:@"AlexALA",USER_CUR_LAT:@"25.0339031",USER_CUR_LON:@"121.5623212"},@{USER_ID_KEY:@"102",USER_NAME_KEY:@"AmyMcDonald",USER_CUR_LAT:@"24.9536701",USER_CUR_LON:@"121.223595"},@{USER_ID_KEY:@"103",USER_NAME_KEY:@"Adam",USER_CUR_LAT:@"24.962072",USER_CUR_LON:@"121.2089793"}]

#define GROUP2 @[@{USER_ID_KEY:@"104",USER_NAME_KEY:@"BenEthen",USER_CUR_LAT:@"24.8599697",USER_CUR_LON:@"121.2058419"},@{USER_ID_KEY:@"105",USER_NAME_KEY:@"BakeryLoaf",USER_CUR_LAT:@"24.9694808",USER_CUR_LON:@"121.1903276"},@{USER_ID_KEY:@"106",USER_NAME_KEY:@"BackStabber",USER_CUR_LAT:@"25.0173405",USER_CUR_LON:@"121.5375631"},@{USER_ID_KEY:@"107",USER_NAME_KEY:@"BackToSchool",USER_CUR_LAT:@"24.178816",USER_CUR_LON:@"120.6445163"}]

#define GROUP3 @[@{USER_ID_KEY:@"108",USER_NAME_KEY:@"CatLady",USER_CUR_LAT:@"24.7859146",USER_CUR_LON:@"120.9945463"},@{USER_ID_KEY:@"109",USER_NAME_KEY:@"CattaPuss",USER_CUR_LAT:@"24.7947253",USER_CUR_LON:@"120.9910429"},@{USER_ID_KEY:@"110",USER_NAME_KEY:@"CalvinKen",USER_CUR_LAT:@"22.736571",USER_CUR_LON:@"121.0657083"},@{USER_ID_KEY:@"111",USER_NAME_KEY:@"CloverChan",USER_CUR_LAT:@"24.150252",USER_CUR_LON:@"120.6843012"}]

static dispatch_once_t onceToken;
static MapViewController *mapviewVC = nil;
@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerview;
@property (weak, nonatomic) IBOutlet UIView *groupView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISwitch *Switch;
@property (strong, nonatomic) NSIndexPath * indexpath;

@end

@implementation MapViewController{
    
    ServerManager * _serverMgr;
    
    double userLat;
    double userLon;
    
    CLLocationManager * cllocationMgr;
    MKAnnotationView * mkAnnotation;
    CLLocation * specificLocation;
    MKPolyline * polyLine;
    UIImage * routeButtonImage;
    
    BOOL shareLocation;
    NSArray * dummyArray;
    NSDictionary * dummyDictionary;
    NSString * chosenGroup;
    MKPolylineView * routeLineView;
    MKPlacemark * destination;
    MKPlacemark * source;
}

+ (instancetype) sharedInstance{
    if (mapviewVC == nil) {
        mapviewVC = [MapViewController new];
    }
    return mapviewVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    cllocationMgr = [CLLocationManager new];
    [_mapview setShowsUserLocation:true];
    shareLocation = false;
    
//    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
//    [tap addTarget:self action:@selector(endEditing)];
//    [self.view addGestureRecognizer:tap];
    
    
    // REQUEST PERMISSION, 為何selector不是requestWhenInUserAuthorization
    if([cllocationMgr respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [cllocationMgr requestWhenInUseAuthorization];
        _mapview.delegate = self;
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"錯誤" message:@"請允許我們用您的定位系統以便讓您享用我們ＡＰＰ的完整服務" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [cllocationMgr setDesiredAccuracy:kCLLocationAccuracyBest];
    [cllocationMgr setActivityType:CLActivityTypeAutomotiveNavigation];
    [cllocationMgr setAllowsBackgroundLocationUpdates:true];
    cllocationMgr.delegate = self;
//    [cllocationMgr startUpdatingLocation];
    
    
    // SETUP PICKERVIEW
    _pickerview.delegate = self;
    _pickerview.dataSource = self;
    
    // SETUP TABLEVIEW
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
    // SETUP GROUP_VIEW
    [_groupView setHidden:true];
    
    
    // SETUP the DUMMY DICTIONARY FOR LATER USE
    /*
     self needed:
     // shall be saved in local database
     1. group_ID
     2. role
     
     keys needed are:
     1. group_ID
     1. user_ID
     2. user_Name
     3. user_Lon
     4. user_Lat
     5. user_PIC
     */
    

    
    dummyDictionary = @{@"groups":@[@"group1",@"group2",@"group3"],
                        @"group1":GROUP1,
                        @"group2":GROUP2,
                        @"group3":GROUP3};
    dummyArray = dummyDictionary[@"groups"];
    
    routeButtonImage = [UIImage imageNamed:@"routeButtonImage.png"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [cllocationMgr startUpdatingLocation];
}

#pragma mark - CLLOCATION
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation * myLocation = locations.lastObject;
    
    CLLocationCoordinate2D myCoordinate = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    
    MKCoordinateRegion  region = MKCoordinateRegionMake(myCoordinate, span);
    
    dispatch_once(&onceToken, ^{
        [_mapview setRegion:region];
//        [self showFriendAnnotation];
    });
    uploadCoordinates* uploadLocations = [uploadCoordinates sharedInstance];
    [uploadLocations reportTheSite:@"http://activeaging.xp3.biz/php/send_coordinates_other.php"];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
}

#pragma mark - PICKER
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return dummyArray.count+1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSMutableArray * tempArray = [NSMutableArray new];
    [tempArray addObject:@"請選擇"];
    [tempArray addObjectsFromArray:dummyArray];
    return  tempArray[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row != 0){
        row = row-1;
        chosenGroup = dummyArray[row];
        
        [_groupView setHidden:false];
        [_tableView reloadData];
    } else {
        [_groupView setHidden:true];
        onceToken = 0;
    }
}

#pragma mark - TABLEVIEW
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * tempArray = dummyDictionary[chosenGroup];
    return tempArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray * tempArray = dummyDictionary[chosenGroup];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    _indexpath = indexPath;
    
    
    cell.textLabel.text = tempArray[_indexpath.row][USER_NAME_KEY];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@,%@)", tempArray[_indexpath.row][USER_CUR_LAT], tempArray[_indexpath.row][USER_CUR_LON]];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [_groupView setHidden:true];
    
    [_mapview removeOverlays:_mapview.overlays]; //Important!
    [_mapview removeAnnotations:_mapview.annotations]; //Important!
    _mapview.userTrackingMode = MKUserTrackingModeFollow;
    [cllocationMgr startUpdatingLocation];
    
    
    NSArray * memberArray = dummyDictionary[chosenGroup];

    NSArray* group1 = GROUP1;
    NSArray* group2 = GROUP2;
    NSArray* group3 = GROUP3;
    _indexpath = indexPath;
        if ([memberArray isEqualToArray:group1]) {
        for (int j = 0; j < GROUP1.count; j++) {
            
            NSMutableArray * locations = [[NSMutableArray alloc] init];
            CLLocationDegrees lat = [GROUP1[j][USER_CUR_LAT] doubleValue];
            CLLocationDegrees lon = [GROUP1[j][USER_CUR_LON] doubleValue];
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
            
            MKPointAnnotation * friendAnnotation = [MKPointAnnotation new];
            
            [friendAnnotation setCoordinate:location];
            [friendAnnotation setTitle:GROUP1[j][USER_ID_KEY]];
            [friendAnnotation setSubtitle:GROUP1[j][USER_NAME_KEY]];
            [locations addObject:friendAnnotation];
            [_mapview addAnnotations:locations];

        }
    }else if ([memberArray isEqualToArray:group2]){
        for (int k = 0; k < GROUP2.count; k++) {
            NSMutableArray * locations = [[NSMutableArray alloc] init];
            CLLocationDegrees lat = [GROUP2[k][USER_CUR_LAT] doubleValue];
            CLLocationDegrees lon = [GROUP2[k][USER_CUR_LON] doubleValue];
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
            
            MKPointAnnotation * familyAnnotation = [MKPointAnnotation new];
            
            [familyAnnotation setCoordinate:location];
            [familyAnnotation setTitle:GROUP2[k][USER_ID_KEY]];
            [familyAnnotation setSubtitle:GROUP2[k][USER_NAME_KEY]];
            [locations addObject:familyAnnotation];
            [_mapview addAnnotations:locations];
        }
    }else if ([memberArray isEqualToArray:group3]) {
        for (int l = 0; l < GROUP3.count; l++) {
            NSMutableArray * locations = [[NSMutableArray alloc] init];
            CLLocationDegrees lat = [GROUP3[l][USER_CUR_LAT] doubleValue];
            CLLocationDegrees lon = [GROUP3[l][USER_CUR_LON] doubleValue];
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
            
            MKPointAnnotation * othersAnnotation = [MKPointAnnotation new];

            [othersAnnotation setCoordinate:location];
            [othersAnnotation setTitle:GROUP3[l][USER_ID_KEY]];
            [othersAnnotation setSubtitle:GROUP3[l][USER_NAME_KEY]];
            [locations addObject:othersAnnotation];
            [_mapview addAnnotations:locations];
        }
    }else{
        return;
    }
    
    userLat = cllocationMgr.location.coordinate.latitude;
    userLon = cllocationMgr.location.coordinate.longitude;
    CLLocationCoordinate2D sourceCoords = CLLocationCoordinate2DMake(userLat, userLon);
    
    CLLocationDegrees lat = [memberArray[_indexpath.row][USER_CUR_LAT] doubleValue];
    CLLocationDegrees lon = [memberArray[_indexpath.row][USER_CUR_LON] doubleValue];
    CLLocationCoordinate2D destCoords = CLLocationCoordinate2DMake(lat, lon);
    
    MKPlacemark *placeMark1 = [[MKPlacemark alloc] initWithCoordinate:sourceCoords addressDictionary:nil];
    MKPlacemark *placemark2 = [[MKPlacemark alloc] initWithCoordinate:destCoords addressDictionary:nil];
    
    source = placeMark1;
    destination = placemark2;
    
    MKMapItem *mapItem1 = [[MKMapItem alloc] initWithPlacemark:destination];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    request.destination = mapItem1;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"ERROR");
             NSLog(@"%@",[error localizedDescription]);
         } else {
             [self showRoute:response];
        }
     }];
    
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    self.routeResponse = response;
   
        for (MKRoute *route in self.routeResponse.routes)
        {
                [_mapview
                 addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
                [_mapview setVisibleMapRect:[route.polyline boundingMapRect]];
                for (MKRouteStep *step in route.steps)
                {
                    NSLog(@"我要的東西：%@", step.instructions);
                }
            
        }
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    renderer.lineWidth = 5.0;
    return  renderer;
}

#pragma mark - MAP
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if (annotation == mapView.userLocation){
        return nil;
    }
    
    MKPinAnnotationView * pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"String"];
    
    pinView.rightCalloutAccessoryView = [self routeButton];
    pinView.canShowCallout = true;
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    
    [self performSegueWithIdentifier:@"nextPage" sender:nil];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    MKRouteStep * step;
    RouteDetailsViewController *receive = segue.destinationViewController;
    
    
    receive.resultArray = [NSMutableArray new];
//    NSArray * memberArray = dummyDictionary[chosenGroup];
    if ([segue.identifier isEqualToString:@"nextPage"])
    {
            for (MKRoute *route in self.routeResponse.routes)
            {
                
                for (step in route.steps)
                {
                    [receive.resultArray addObject:step.instructions];
                    NSLog(@"yoyo: %@", step.instructions);
                }
                
                
            }

        
    }
}

- (UIButton *) routeButton{
    
    UIImage *image = [UIImage imageNamed:@"routeIcon.jpg"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height); // don't use auto layout
    [button setImage:image forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    return button;
}


//- (void) buttonTapped:(id)sender{
//    
//    self.routeResponse = responses;
//    self.route = routes;
//    self.step = steps;
//    
//    for (routes in self.routeResponse.routes)
//    {
//            for (steps in self.route.steps)
//        {
//            NSLog(@"我要的東西：%@", steps.instructions);
//        }
//        
//    }
//}

#pragma mark - BUTTONS
- (IBAction)returnButtonPresssed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
    //aa
}

- (IBAction)shouldShareLocationSwitch:(id)sender {
    if (_Switch.on){
        shareLocation = true;
        _mapview.userTrackingMode = MKUserTrackingModeFollow;
        [cllocationMgr startUpdatingLocation];
    }else{
        shareLocation = false;
        _mapview.userTrackingMode = MKUserTrackingModeNone;
        [cllocationMgr stopUpdatingLocation];
    }
}
- (void) endEditing{
    [self.view endEditing:true];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
