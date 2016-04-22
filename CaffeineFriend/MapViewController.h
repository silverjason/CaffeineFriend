//
//  ViewController.h
//  CaffeineFriend
//
//  Created by Jason Silver on 21/04/2016.
//  Copyright © 2016 Jason Silver. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface MapViewController : UIViewController

typedef void(^myCompletion)(BOOL,NSArray*);

- (void) sortVenueDataFor:(NSArray*)venuesArray withBlock:(myCompletion) compblock;



@end

