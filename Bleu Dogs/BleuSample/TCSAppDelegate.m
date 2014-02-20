//
//  TCSAppDelegate.m
//  BeaconBump
//
//  Created by Tim Perfitt on 10/4/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import "TCSAppDelegate.h"
#import "TCSBleuBeaconManager.h"

@interface TCSAppDelegate (){
}

@end


@implementation TCSAppDelegate 

+ (void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    


    
	[defaults registerDefaults:@{@"bleuConfigURL": @"https://dl.dropboxusercontent.com/u/5770480/default.plist",
                                 @"region1uuid":@"e2c56db5-dffb-48d2-b060-d0f5a71096e0",
                                 @"region2uuid":@"e2c56db5-dffb-48d2-b060-d0f5a71096e0",
                                 @"region3uuid":@"e2c56db5-dffb-48d2-b060-d0f5a71096e0",
                                 @"region1major":[NSNumber numberWithInt:1],
                                @"region2major":[NSNumber numberWithInt:1],
                                @"region3major":[NSNumber numberWithInt:1],
                                 @"region1minor":[NSNumber numberWithInt:1],
                                 @"region2minor":[NSNumber numberWithInt:1],
                                 @"region3minor":[NSNumber numberWithInt:1]

                                 
                                 
                                 
                                 }];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}
- (void)applicationDidEnterBackground:(UIApplication *)application{
//    NSLog(@"Going into background.  Resetting");
//
//
//    [[TCSBleuBeaconManager sharedManager] beginRegionMonitoring];

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    
    [nc postNotificationName:@"TCSBeaconFound" object:self userInfo:notification.userInfo];
    
}
@end
