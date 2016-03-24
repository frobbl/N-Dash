//
//  WeatherService.h
//  SimpSoft LLC
//
//  Created by John Schilling on 3/14/16.
//  Copyright © 2016 SimpSoft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class WeatherService;

@protocol WeatherServiceDelegate

- (void)weatherService:(WeatherService *)service willBeginDownloadingForLocation:(CLLocation *)location;
- (void)weatherService:(WeatherService *)service didUpdateForLocation:(CLLocation *)location
               celsius:(double)celsius fahrenheit:(double)fahrenheit placename:(NSString *)placename;
- (void)weatherService:(WeatherService *)service stationLocationDidChange:(CLLocation *)newLocation
           oldLocation:(CLLocation *)oldLocation stationName:(NSString *)stationName;
- (void)weatherService:(WeatherService *)service failedToUpdateWithError:(NSError *)error;
- (void)weatherService:(WeatherService *)service didBecomeInvalidWithError:(NSError *)error;

@end

@interface WeatherService : NSObject <NSURLSessionDelegate>

- (id)initWithDelegate:(id<WeatherServiceDelegate>)initdelegate location:(CLLocation *)initlocation
        updateInterval:(double)initinterval autoUpdates:(BOOL)initauto beginDownloading:(BOOL)begin;
- (void)updateLocation:(CLLocation *)location andUpdateImmediately:(BOOL)update;
- (void)updateWeather;
- (void)startAutoUpdating;
- (void)stopAutoUpdating;
- (void)setAutoUpdateInterval:(int)interval;

@property (nonatomic, assign) id  delegate;

@property (nonatomic, copy)     CLLocation *urllocation;
@property (nonatomic, copy)     CLLocation *stlocation;
@property (nonatomic, copy)     NSMutableString *weatherurl;
@property (nonatomic, copy)     NSMutableString *placename;
@property (nonatomic, copy)     NSMutableString *METAR;
@property (nonatomic) double    celsius;
@property (nonatomic) double    fahrenheit;
@property (nonatomic) int       elevation;
@property (nonatomic) double    updateinterval;
@property (nonatomic) BOOL      autoupdates;

@end




/*
 
 DONT FORGET! Add the following property to your application's info.plist:
 
 <key>NSExceptionDomains</key>
	<dict>
 <key>forecast.weather.gov</key>
 <dict>
 <key>NSIncludesSubdomains</key>
 <true/>
 <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
 <true/>
 <key>NSTemporaryExceptionMinimumTLSVersion</key>
 <string>TLSv1.1</string>
 </dict>
	</dict>
 
 */