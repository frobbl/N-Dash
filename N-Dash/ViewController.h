//
//  ViewController.h
//  N-Dash
//
//  Created by John Schilling on 3/11/16.
//  Copyright © 2016 StimSoft LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "WeatherService.h"
#import "EDSunriseSet.h"

@interface ViewController : UIViewController <WeatherServiceDelegate,CLLocationManagerDelegate>
{
    
}
@end

