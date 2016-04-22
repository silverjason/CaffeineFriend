//
//  ViewController.m
//  CaffeineFriend
//
//  Created by Jason Silver on 21/04/2016.
//  Copyright © 2016 Jason Silver. All rights reserved.
//

#import "MapViewController.h"
#import <RestKit/RestKit.h>
#import "ListViewControllerTableViewController.h"
#import "VenueObject.h"
#import "ListViewControllerTableViewController.h"
@import CoreLocation;


@interface MapViewController() <CLLocationManagerDelegate> {

}
@property (retain, nonatomic) IBOutlet GMSMapView *mapView;
@property(nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *venues;




@end

@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureRestKit];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    //Change update every 100 meters
    self.locationManager.distanceFilter = 100.0;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 100 m
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton= YES;
    

    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    

    
}

- (void) viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit with client
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[VenueObject class]];
    [venueMapping addAttributeMappingsFromArray:@[@"name"]];
    [venueMapping addAttributeMappingsFromArray:@[@"location"]];

    
    // register mappings with the provider using a response descriptor
    // use search endpoint
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/v2/venues/search"
                                                keyPath:@"response.venues"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

- (void)loadVenuesUsingLatitude:(NSString*)latitude longitude:(NSString*)longitude
{
    NSString *latLon = latitude;
    latLon = [latLon stringByAppendingString:@","];
    latLon = [latLon stringByAppendingString:longitude];
    
    
    //Foursqaure credentials
    NSString *clientID = @"KY0RFH3HKB4GC5WBVKOQWHUWAHHILIMWHQT32HGQETGZY2AX";
    NSString *clientSecret = @"3QPQ0HQ5WBEIKTS51APAWD0I51205JXG5I40QRAGZTQAUBUP";
    
    
    // 4 KM Radius
    // Use coffee category ID
    // Limit to 100 results
    NSDictionary *queryParams = @{@"ll" : latLon,
                                  @"client_id" : clientID,
                                  @"client_secret" : clientSecret,
                                  @"categoryId" : @"4bf58dd8d48988d1e0931735",
                                  @"limit" : @"100",
                                  @"radius" : @"4000",
                                  @"v" : @"20140806"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _venues = mappingResult.array;
                                                  [self processData];
                                                  [self createCustomMarkers];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];
}


- (void) processData {
    
    
    // Sort in ascending order using distance
    
    NSComparisonResult (^sortBlock)(id, id) = ^(id obj1, id obj2) {
        NSNumber * distance1 = [[obj1 valueForKey:@"location"] valueForKey:@"distance"][0];
        NSNumber * distance2 = [[obj2 valueForKey:@"location"] valueForKey:@"distance"][0];
        if (distance1 > distance2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (distance1 < distance2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    self.venues = [self.venues sortedArrayUsingComparator:sortBlock];
    
    
    
}

- (void) createCustomMarkers{
    
    // Loop through venues and create markers for each
    
    for (VenueObject * venue in self.venues) {
        
        NSNumber* latitude = [venue.location valueForKey:@"lat"][0];
        NSNumber* longitude = [venue.location valueForKey:@"lng"][0];
        double lat = [latitude doubleValue];
        double lng = [longitude doubleValue];

        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(lat, lng);
        marker.title = venue.name;
        
        NSString * snippet = [venue.location valueForKey:@"address"][0];
        if (snippet == nil || [snippet isKindOfClass:[NSNull class]]) {
            snippet = @"No Address Found";
        }
    
        NSString * distance = [NSString stringWithFormat:@"%@", [venue.location valueForKey:@"distance"][0]];

        snippet = [snippet  stringByAppendingString:@" ("];
        snippet = [snippet  stringByAppendingString:distance];
        snippet = [snippet  stringByAppendingString:@"m)"];
        marker.snippet = snippet;

        marker.map = self.mapView;
    }
    
}


/* Delegate method fired when current location is changed */

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];

        NSString * latitude = [NSString stringWithFormat:@"%.20f", location.coordinate.latitude];
        NSString * longitude = [NSString stringWithFormat:@"%.20f", location.coordinate.longitude];
    
        // Load venues for updated location
        [self loadVenuesUsingLatitude:latitude longitude:longitude];
    
        // Adjust camera to current location
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                             zoom:14];
    
}




- (IBAction)viewList:(id)sender {
    
    // Navigate to list viewcontroller
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    ListViewControllerTableViewController *listViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ListViewController"];
    
    listViewController.venues = self.venues;
    
    [self.navigationController pushViewController:listViewController animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
