//
//  TCSBleuStation.h
//  Bleu Setup
//
//  Created by Steve Brokaw on 10/31/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 Errors codes for errors in domain TCSBleuStationErrorDomain. 
 */
typedef NS_ENUM(NSInteger, TCSBleuStationErrorCode) {
/**
Error from an asynchronous property read.
 */
    TCSBleuStationErrorRead = 1,
/**
 The value submitted for writing failed valdation tests. It may be a the wrong
 class, or an invalid format (e.g., a string that doesn't convert to a UUID).
 */
    TCSBleuStationErrorInvalidValue,
/**
 The value passed validation but encountered other errors while writing.
 */
    TCSBleuStationErrorWrite,
/**
 Error from a failed authentication. This error indicated the authentication
 attempt was made but the station denied the authentication because of an invalid
 password.
 */
    TCSBleuStationErrorAuthenticationFailed,
/**
 Error after too many bad authentication attempts. If you receive this error,
 the userInfo dictionary will contain values for two additional keys:
 TCSBleuStationAuthenticationDelay and TCSBleuStationAuthenticationFailures.
 */
    TCSBleuStationErrorAuthenticationBlocked,
};

/**
 The error domain for TCSBleuStation.
 */
NSString * const TCSBleuStationErrorDomain;

/**
 This is a key in the userInfo dictionary for errors of type
 TCSBleuStationErrorAuthenticationBlocked. The value is an NSNumber indicating
 the seconds until the Bleu Station will attempt another authentication.
 */
NSString * const TCSBleuStationAuthenticationDelay;

/**
 This is a key in the userInfo dictionary for errors of type
 TCSBleuStationErrorAuthenticationBlocked. The value is an NSNumber indicating
 the times an incorrect password has been tried with the Bleu Station.
 */
NSString * const TCSBleuStationAuthenticationFailures;


/**
 Constants for the keys in dictionaries with the asynchronous methods and
 delegate callbacks.
 
 It is an error to attempt to read a value of type TCSBleuStationPassword.
 It is an error to attempt to write a value of type TCSBleuStationAllProperties.
 */
NSString * const TCSBleuStationProximityUUID;
NSString * const TCSBleuStationMajor;
NSString * const TCSBleuStationMinor;
NSString * const TCSBleuStationName;
NSString * const TCSBleuStationPassword;
NSString * const TCSBleuStationPower;
NSString * const TCSBleuStationCalibration;
NSString * const TCSBleuStationLatitude;
NSString * const TCSBleuStationLongitude;
NSString * const TCSBleuStationURL;
NSString * const TCSBleuStationHardwareVersion;
NSString * const TCSBleuStationFirmwareVersion;
NSString * const TCSBleuStationAllProperties;

@class TCSBleuStation;

/**
 Delegate callbacks for reading and writing attributes on a Bleu Station. One or
 more values will be passed in the _values_ dictionary. In the case of an error,
 the an error object will be returned and values will be nil.
 */
@protocol TCSBleuStationDelegate <NSObject>

@optional

/**
 Delegate callback in resonse to readValues:.
 
 In the case of an error, the _property_ parameter will have the name of the
 propery the library was attempting to write, and the _value_ parameters will be
 nil.
 
 @param station A reference to the Bleu Station reading the values.
 @param property The key that identifies the property read.
 @param value The value of the property. The type will match the type of
 the respective Objective-C property.
 @param error Any errors encountered reading a value.
 */
- (void)station:(TCSBleuStation *)station didReadProperty:(NSString *)property value:(id)value error:(NSError *)error;

/**
 Delegate callback in resonse to writeValues:.
 
 If error is nil, the write was a success. Otherwise the value was not written.
 In the case of an error, the _property_ parameter will contain the key libbleu
 was attempting to write when the error occurred. Depending on the nature of the
 error, the value may nil if the library doesn't have access to the value it
 was attempting to write.
 
 @param station A reference to the Bleu Station writing the values.
 @param property The key that identifies the property written.
 @param value The value from the original writeValues: call, if available.
 @param error Any errors encountered reading a value.
 
 */
- (void)station:(TCSBleuStation *)station didWriteProperty:(NSString *)property value:(id)value error:(NSError *)error;

/**
 Delegate callback in response to authenticateWithPassword:
 
 @param station A reference to the authenticating Bleu Station.
 @param error Any error encountered. On a successful authentication this call
 will be made with a nil error.
 */
- (void)station:(TCSBleuStation *)station didAuthenticateError:(NSError *)error;

@end

/**
 A TCSBleuStation represents a Bleu Station and is the interface to reading and
 writing values to a blue station from an iOS device. Objects of class
 TCSBleuStation are created by a TCSBleuStationManager object.
 
There are two ways to access
 the properties of a Bleu Station: synchronously, using properties, and
 asynchronously, using a delegate.
 
 **Asynchronous Reads**
 
 An asynchronous read will always trigger Bluetooth to read from the
 Blue Station, so you are guaranteed the latest information. The method
 
    - (void)readValues:(NSArray *)values;
 
 will communicate with the Bleu Station over Bluetooth. When the Bleu Station
 returns the result, either with the value or with an error, the corresponding
 delegate method is called.
 
     – station:didReadValues:error:
 
 **Synchronous Read via Propertiies**
 
 Once a TCSBleuStation object has retrieved values from a Bleu Station, those
 values are accessible via properties. All properties in a TCSBleuStation should
 be considered cached copies of the result of the last asynchronous read. If a
 Bleu Station hasn't read a given property yet, the property will return nil. In
 this case a call to the asynchronous method is required.
 
 Reading and writing
 to a Blue Station is a high latency operation which impacts battery life, so
 values are not read by default. If you expect you'll need access to all the properties
 (for example, for a master-detail interface), you can issue an asynchronous read
 for the property TCSBleuStationAllProperties. That will read all values from the
 station, store the cached values, and make them available via properties.
 
 **Writing Values**
 
 All object properties are read-only. The only way to write to a Bleu Station is using
 the asynchronous write call `- (void)writeValues:(NSDictionary *)values;`. See
 above for the keys for each of the properties properties.
 
 **The hardwareName Property**
 
 The hardwareName is unique in two ways:
 
 1. It available prior to any asynchronous read.
 1. It is based on the MAC adddress, and can be used to idenify a Bleu Station
 
 In deploying Bleu Stations, you can identify a station using the hardwareName,
 then write a set of appropriate values, all without issuing a single
 asynchronous read.

 **Authentication**
 
 Before writing any values you must authenticate with the Bleu Station. Calling
 authenticateWithPassword: will trigger a Bluetooth pairing dialog on the device.
 This sets up an encrypted connection before the password is sent to the station.
 
 **Constants**
 
 In addition to the enumerations documented in TCSBleuStationErrorCode, there are
 several string constants documented in the header file. These are for accessing
 addtional information from the userInfo dictionary included in the NSError
 objects.
 */



@interface TCSBleuStation : NSObject

/** The proximity UUID used in the beacon advertisement packet. */
@property (readonly) NSString *proximityUUID;

/** The major number used in the beacon advertisement packet. */
@property (readonly) NSNumber *major;

/** The minor number used in the beacon advertisement packet. */
@property (readonly) NSNumber *minor;

/** A constant name derived in part from the bleu stations unique MAC adddress.
 This name uniquely identifies a Bleu Station and cannot be changed. */
@property (readonly) NSString *hardwareName;

/** A user configurable name. */
@property (readonly) NSString *name;

/** The power output of the Bleu Station in decibels. In theory, this number
 should be the reciprocal of the RSSI reported by the device. */
@property (readonly) NSNumber *power;

/** Calibration which can help determine distance when combined with RSSI.*/
@property (readonly) NSNumber *calibration;

/** The latitude of the beacon. Beacons do not discover their coordinates, and
 this must be set manually to be accurate. */
@property (readonly) NSNumber *latitude;

/** The longitude of the beacon. */
@property (readonly) NSNumber *longitude;

/** A url. This can be used to point to settings stored on a server, for example.
 It is up to the app to resolve the url and load the settings.*/
@property (readonly) NSString *URL;

/** The hardware version of the Bleu Station. This is a string in dotted decimal
 format of MAJOR.MINOR.PATCH. */
@property (readonly) NSString *hardwareVersion;

/** The firmware version of the Bleu Station. This is a string in dotted decimal
 format of MAJOR.MINOR.PATCH. */
@property (readonly) NSString *firmwareVersion;

/** The delegate */
@property id<TCSBleuStationDelegate> delegate;

/**
 Asynchronous method to write one or more values to the Bleu Station.
 
 As values are written, it will call the delegate. For a given batch of values,
 there might be multiple delegate calls. Write calls including the key
 TCSBleuStationAllProperties will return an error for that key. Other keys included
 in the _values_ will proceed to write.
 
 The type for each key is same as the related property type. For example, the type
 of the proximityUUID property is NSString; the type of the value for key
 TCSBleuStationProximityUUID is an NSString. All value types for BleuStations are
 supported by plists. This makes it easy to configure a station using a set of
 values retrieved from a plist, from a JSON object, or other archived formats.
 
 @param values A dictionary of values to write. See the overview for a list of
 key values.
 
 @see TCSBleuStationDelegate
 */
- (void)writeValues:(NSDictionary *)values;

/**
 Asynchronous method to retrieve values from the Bleu Station. _values_ is an
 array of keys defined above.
 
 If you want to read all values, pass an array containing
 TCSBleuStationAllProperties.
 
 Attempts to read TCSBleuStationPassword will always return an error.

 See TCSBleuStation.h for the keys for the _values_ dictionary.
 
 @param values An array of keys to read.
 
 @see [TCSBleuStationDelegate station:didReadProperty:value:error:]
 */
- (void)readValues:(NSArray *)values;

/**
 Authenticate to the Bleu Station. Authentication results are returned in the delegate
 call station:didAuthenitcateError.
 
 If you attempt to authenticate an get no response, you may have a pairing issue.
 You can reset both the Bleu Station and the device following the troubleshooting
 section of the [support doc](http://twocanoes.com/bleu-station/support/setting-up-bleu-station-with-the-bleu-setup-ios-app).
 
 @param password The cleartext password.
 @see [TCSBleuStationDelegate station:didAuthenticateError:]
 */
- (void)authenticateWithPassword:(NSString *)password;
@end
