//
//  MainView.h
//  N-Dash
//
//  Created by John Schilling on 3/25/16.
//  Copyright © 2016 StimpSoft, Inc.™ LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "WeatherService.h"
#import "EDSunriseSet.h"
#import "Spectrum.h"
#import "PreferencesViewController.h"

@interface MainViewController : UIViewController <WeatherServiceDelegate,CLLocationManagerDelegate>
{
    
}

@end

