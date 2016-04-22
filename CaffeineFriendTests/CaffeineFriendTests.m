//
//  CaffeineFriendTests.m
//  CaffeineFriendTests
//
//  Created by Jason Silver on 21/04/2016.
//  Copyright © 2016 Jason Silver. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MapViewController.h"
#import "VenueObject.h"

@interface CaffeineFriendTests : XCTestCase
@property (nonatomic) MapViewController *mapVC;

@end

@implementation CaffeineFriendTests

- (void)setUp {
    [super setUp];
    self.mapVC = [[MapViewController alloc] init];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void) testSortVenueData{
    
    
    // Set  up array in mixed distance order
    
    VenueObject *venueOne = [[VenueObject alloc] init];
    VenueObject *venueTwo = [[VenueObject alloc] init];
    VenueObject *venueThree = [[VenueObject alloc] init];
    VenueObject *venueFour = [[VenueObject alloc] init];
    
    venueOne.name = @"Espresso Love";
    venueTwo.name = @"Coffee Craver";
    venueThree.name = @"Caffeine Dream";
    venueFour.name = @"One Stop Shot";
    
    venueOne.location = [[NSMutableArray alloc] init];
    venueTwo.location = [[NSMutableArray alloc] init];
    venueThree.location = [[NSMutableArray alloc] init];
    venueFour.location = [[NSMutableArray alloc] init];
    
    NSDictionary * dictOne = @{@"distance" :@(4000)};
    NSDictionary * dictTwo = @{@"distance" :@(1000)};
    NSDictionary * dictThree = @{@"distance" :@(3000)};
    NSDictionary * dictFour = @{@"distance" :@(2000)};
    
    [venueOne.location addObject:dictOne];
    [venueTwo.location addObject:dictTwo];
    [venueThree.location addObject:dictThree];
    [venueFour.location addObject:dictFour];
    
    NSArray *venuesTest = [[NSArray alloc] initWithObjects: venueOne, venueTwo, venueThree, venueFour,nil];
    
    // sort array and check if order is correct
    
    [self.mapVC sortVenueDataFor:venuesTest withBlock:^(BOOL finished, NSArray *result) {
        
        XCTAssertEqualObjects([result[0] valueForKey:@"name"], @"Coffee Craver", @"Incorrect Match");
        XCTAssertEqualObjects([result[1] valueForKey:@"name"], @"One Stop Shot", @"Incorrect Match");
        XCTAssertEqualObjects([result[2] valueForKey:@"name"], @"Caffeine Dream", @"Incorrect Match");
        XCTAssertEqualObjects([result[3] valueForKey:@"name"], @"Espresso Love", @"Incorrect Match");

    }];


}


- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
