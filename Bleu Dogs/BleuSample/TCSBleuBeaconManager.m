//
//  TCSBleuURLMapper.m
//  Bleu
//
//  Created by Steve Brokaw on 10/15/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TCSBleuBeaconManager.h"

NSString * const TCSDidEnterBleuRegionNotification = @"TCSDidEnterBleuRegionNotification";
NSString * const TCSDidExitBleuRegionNotification = @"TCSDidExitBleuRegionNotification";
NSString * const TCSBleuRangingNotification = @"TCSBleuRangingNotification";

@interface TCSBleuBeaconManager()
@property (nonatomic, strong) NSMutableDictionary *URLStore;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, readwrite) NSString *defaultURL;
@property (strong, readwrite) NSString *entryText;
@property (strong, readwrite) NSString *exitText;

@end

@implementation TCSBleuBeaconManager
@synthesize URLStore = _URLStore;

+ (instancetype)sharedManager {
	static TCSBleuBeaconManager *_sharedManager;
	
	if (!_sharedManager) {
		_sharedManager = [[[self class] alloc] init];
		_sharedManager->_URLStore = [NSMutableDictionary dictionary];
			CLLocationManager *locationManager = [[CLLocationManager alloc] init];
			locationManager.delegate = _sharedManager;
			//These two settings sacrifice battery life for a smoother demo experience.
			[locationManager disallowDeferredLocationUpdates];
			locationManager.pausesLocationUpdatesAutomatically = NO;
			
			_sharedManager->_locationManager = locationManager;
		
		
	}
	return _sharedManager;
}


- (NSArray *)URLsForUUID:(NSString *)UUID major:(NSString *)major minor:(NSString *)minor
{

	NSString *key = [[NSString stringWithFormat:@"%@:%@:%@", UUID, major, minor] uppercaseString];
	@synchronized(self) {
		return self.URLStore[key];
	}
}

- (void)addMappingWithDictionary:(NSDictionary *)mappingDict
{
	NSString *UUID = [mappingDict[@"proximityUUID"] uppercaseString];
	NSDictionary *URLs = mappingDict[@"URLs"];
	self.defaultURL = mappingDict[@"defaultURL"];
	self.entryText = mappingDict[@"entryText"];
	self.exitText = mappingDict[@"exitText"];
	NSArray *majorKeys = [URLs allKeys];
	for (NSString *majorKey in majorKeys) {
		NSDictionary *minorStations = URLs[majorKey];
		NSArray *minorKeys = [minorStations allKeys];
		for (NSString *minorKey in minorKeys) {
			NSArray *stationURLs = minorStations[minorKey];
			NSString *mappingKey = [NSString stringWithFormat:@"%@:%@:%@", UUID, majorKey, minorKey];
			@synchronized(self) {
				self.URLStore[mappingKey] = stationURLs;
			}
		}
	}
}

- (void)beginRegionMonitoring{

    
	NSArray *regionKeys;
	@synchronized(self) {
		regionKeys = [self.URLStore allKeys];
	}
    
//	for (NSString *key in regionKeys) {
//		NSArray *regionTriplet = [key componentsSeparatedByString:@":"];


    
    
    NSSet *monitoredRegions=[self.locationManager monitoredRegions];
    
    for (CLBeaconRegion *region in monitoredRegions) {
        
        [self.locationManager stopMonitoringForRegion:region];
        
    }
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    CLBeaconRegion *region1 = [[CLBeaconRegion alloc]
                               initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[ud objectForKey:@"region1uuid"]]
                               major:[[ud objectForKey:@"region1major"] integerValue]
                               minor:[[ud objectForKey:@"region1minor"] integerValue]
                               identifier:@"com.twocanoes.one"];
    
    
    CLBeaconRegion *region2 = [[CLBeaconRegion alloc]
                               initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[ud objectForKey:@"region2uuid"]]
                               major:[[ud objectForKey:@"region2major"] integerValue]
                               minor:[[ud objectForKey:@"region2minor"] integerValue]
                               identifier:@"com.twocanoes.two"];

    
    CLBeaconRegion *region3 = [[CLBeaconRegion alloc]
                               initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[ud objectForKey:@"region3uuid"]]
                               major:[[ud objectForKey:@"region3major"] integerValue]
                               minor:[[ud objectForKey:@"region3minor"] integerValue]
                               identifier:@"com.twocanoes.three"];

    
    
    
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self.locationManager startMonitoringForRegion:region1];
			[self.locationManager startMonitoringForRegion:region2];
			[self.locationManager startMonitoringForRegion:region3];
            
		}];
	
	
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	DLog(@"Entered Region");
	UIApplicationState state = [[UIApplication sharedApplication] applicationState];
	switch (state) {
		case UIApplicationStateInactive:
		case UIApplicationStateActive:
			[[NSNotificationCenter defaultCenter] postNotificationName:TCSDidEnterBleuRegionNotification
																object:self
															  userInfo:@{@"region": region}];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TCSBeaconFound" object:self userInfo:@{@"identifier":region.identifier}];


			break;
		case UIApplicationStateBackground: {
            UILocalNotification *notification = [[UILocalNotification alloc] init];

            if ([region.identifier isEqualToString:@"com.twocanoes.one"]) {
                notification.alertBody = @"Welcome to Bob's Hotdog Palace.  Check out our menu.";
                notification.userInfo=@{@"identifier":@"com.twocanoes.one"};
            }
            
            else if ([region.identifier isEqualToString:@"com.twocanoes.two"]) {
                notification.alertBody = @"Slide or tap to checkout with your Bob's hotdog loyalty card.";
                notification.userInfo=@{@"identifier":@"com.twocanoes.two"};

            }
            else if ([region.identifier isEqualToString:@"com.twocanoes.three"]) {
                notification.alertBody = @"Please don't put ketchup on hotdogs.  That is disgusting.";
                notification.userInfo=@{@"identifier":@"com.twocanoes.three"};

                
            }

			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		}
		default:
			break;
	}

}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	DLog(@"Exited Region");
	UIApplicationState state = [[UIApplication sharedApplication] applicationState];
	switch (state) {
		case UIApplicationStateInactive:
		case UIApplicationStateActive:
			[[NSNotificationCenter defaultCenter] postNotificationName:TCSDidExitBleuRegionNotification
																object:self
															  userInfo:@{@"region": region}];

			break;
		case UIApplicationStateBackground:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            
            if ([region.identifier isEqualToString:@"com.twocanoes.one"]) {
                notification.alertBody = @"DEBUG: EXITED com.twocanoes.one";
                notification.userInfo=@{@"identifier":@"com.twocanoes.one"};
            }
            
            else if ([region.identifier isEqualToString:@"com.twocanoes.two"]) {
                notification.alertBody = @"DEBUG: EXITED com.twocanoes.two";
                notification.userInfo=@{@"identifier":@"com.twocanoes.two"};
                
            }
            else if ([region.identifier isEqualToString:@"com.twocanoes.three"]) {
                notification.alertBody = @"DEBUG: EXITED com.twocanoes.three";
                notification.userInfo=@{@"identifier":@"com.twocanoes.three"};
                
                
            }
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		}
		default:
			break;
	}
	[manager startMonitoringForRegion:region];
}



@end
