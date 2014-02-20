//
//  TCSBleuStationComm.h
//  Bleu Setup
//
//  Created by Steve Brokaw on 10/31/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 A key for the user defaults. See the value to YES to turn on detailed logging
 from the library.
 */
NSString * const TCSLibbleuDebugLogging;

/**
 The build nubmber for the library.
 */
extern const unsigned int TCSLibbleuBuildNumber;
/**
 The version for the library. This will be a dotted decimal version of the form
 MAJOR.MINOR.PATCH. Prerelease version may include additional characters.
 */
extern const unsigned char TCSLibbleuVersionNumber[];

/**
 Error codes for errors in domain TCSBleuStationManagerErrorDomain
 */
typedef NS_ENUM(NSInteger, TCSBleuStationManagerErrorCode) {
    
/**
 There is a problem with the Bluetooth Central on this device. This may be because
 the user disallowed Bluetooth access to the app, bluetooth is powered off, or
 the hardware doesn't support it.
 */
    TCSBleuStationManagerErrorCentral,
    
/**
 The Bluetooth Central found a Bluetooth peripheral, but was unable to connect.
 At the time of this error, it is unknown yet whether the peripheral is a Bleu
 Station or another kind of Bluetooth LE device.
 */
    TCSBleuStationManagerErrorConnection

};

/**
 The name of the error domain found in NSError objects.
 */
NSString * const TCSBleuStationManagerErrorDomain;

@class TCSBleuStation, TCSBleuStationManager;

/**
 Callbacks when the manager discovers Bleu Stations, disconnects a Bleu Station,
 or encounters an error.
 */
@protocol TCSBleuStationManagerDelegate <NSObject>

/**
 Called when a Bleu Station is discovered while scanning.
 
 The station manager does not maintain a reference to any stations it finds. You
 must keep a reference to keep the connection alive.
 
 @param manager A reference to the Bleu Station Manager makig the call.
 @param station The Bleu Station discovered by the Station Manager.
 */
- (void)stationManager:(TCSBleuStationManager *)manager didDiscoverStation:(TCSBleuStation *)station;

/**
 Called when a station disconnects, for example because it has moved out of range.
 
 Once a station disconnects, references to it are no longer valid, and any
 asynchronous calls to read property values will fail. If you are keeping a
 reference to the station, you can identify the object to release by comparing
 the station's harwareName property to the harwareName parameter passed by this
 delegate call.
 
 @param manager The a reference to the station manger making the call.
 @param hardwareName The hardware name of the Bleu Station.
 */
- (void)stationManager:(TCSBleuStationManager *)manager didDisconnectStationWithIdentifier:(NSString *)hardwareName;

/**
 Called when a failure occurs. These typically represent error interacting with
 the bluetooth stack.
 
 See errors documented above.
 
 @param manager The a reference to the station manger making the call.
 @param error An error with the details of the problem.
 */
- (void)stationManager:(TCSBleuStationManager *)manager didFailWithError:(NSError *)error;

@end

/**
 The manager is responsible for finding and reporting nearby Bleu Stations.
  */

@interface TCSBleuStationManager : NSObject

@property (weak) id<TCSBleuStationManagerDelegate> delegate;

/**
 Initialzes a new Bleu Station Manager.
 
 Passing a nil queue will cause the station manager to make all delegate calls
 on the main queue. Calling init has the same effect as passing a nil queue.
 
 @param queue The dispatch queue on which all delegate calls will be made.
 @param delegate The delegate
 */
- (instancetype)initWithDelegate:(id<TCSBleuStationManagerDelegate>)delegate queue:(dispatch_queue_t)queue;

/**
 Scans for Bleu Stations over Bluetooth.
 
 Any discovered stations are passed back with the delegate
 call stationManager:didFindStation: Scans started with this method will
 never terminate without calling stopScan. Be careful using this call as it can
 result is rapid battery drain.
 
 @see [TCSBleuStationManagerDelegate stationManager:didDiscoverStation:]
 */
- (void)scanForStations;

/**
 Scans for Bleu stations for a finite duration.

 Once the scan has timed out it is not necessary to call stopScan. It is safe
 to call stopScan before a specified timeout has expired.

 @param timeout Duration the scan is active before timing out.
 */
- (void)scanForStationsTimeout:(NSTimeInterval)timeout;

/**
 Stop scanning for Bleu Stations. This call is required if you started the scan
 using scanForStations.
 */
- (void)stopScan;

@end
