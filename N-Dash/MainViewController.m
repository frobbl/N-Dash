//
//  ViewController.m
//  N-Dash
//
//  Created by John Schilling on 3/11/16.
//  Copyright © 2016 StimSoft LLC. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController ()

@property (weak, nonatomic) PreferencesViewController  *preffy;

@property (weak, nonatomic) IBOutlet MKMapView      *MapView;

@property (weak, nonatomic) IBOutlet UIButton       *SpeedButton;
@property (weak, nonatomic) IBOutlet UILabel        *SpeedFractionLabel;
@property (weak, nonatomic) IBOutlet UILabel        *SpeedUnitsLabel;

@property (weak, nonatomic) IBOutlet UIButton       *TempButton;
@property (weak, nonatomic) IBOutlet UIButton       *AltitudeButton;
@property (weak, nonatomic) IBOutlet UIButton       *HeadingButton;
@property (weak, nonatomic) IBOutlet UIButton       *OdometerLabel;
@property (weak, nonatomic) IBOutlet UIButton       *OdometerButton;
@property (weak, nonatomic) IBOutlet UIButton       *DirectDistanceButton;
@property (weak, nonatomic) IBOutlet UILabel        *DirectDistanceLabel;
@property (weak, nonatomic) IBOutlet UIButton       *LocationButton;
@property (weak, nonatomic) IBOutlet UIButton       *ClockButton;
@property (weak, nonatomic) IBOutlet UILabel        *SunLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *WeatherSpinner;

- (void)loadPrefernces;
- (void)savePreferences;
- (void)cleanInterface;
- (void)initWeatherService;
- (void)initLocationManager;

- (void)getCurrentTemperature;

- (void)centerMapView:(double)zoomLevelLat longitudeSpan:(double)zoomLevelLon;
- (double)mapViewZoomLevelLatitude;
- (double)mapViewZoomLevelLongitude;

- (void)setSpeedButtonLabel:(double)fmps;
- (void)setOdometerButtonLabel:(double)metersA metersB:(double)metersB;
- (void)setAltitudeButtonLabel:(double)meters;
- (void)setHeadingButtonLabel:(int)heading;
- (void)setTempButtonLabel:(double)celsius;
- (void)setClockButtonLabel;
- (void)setLocationButtonLabel:(NSString *)location;
- (void)setSunLabel;

- (NSString *)directionForHeading:(int)heading;
- (void)getCurrentLocationName;

- (void)toggleSpeedUnitsState;
- (void)toggleUSERDEFTemperatureUnits;
- (void)toggleOdometerViewState;

- (UIColor *)colorForTemperatureInFahrenheit:(int)temp;
- (UIColor *)colorForSpeed:(double)mps;
- (NSString *)formattedStringFromDate:(NSDate *)date;
- (NSString *)timeUntilDateFormatted:(NSDate *)date;
- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;


@property (nonatomic) BOOL                                  BOOGEYMODE;
@property (nonatomic) double                                BOOGEYSPEED;

@property (nonatomic, strong) CLLocationManager             *locationManager;
@property (nonatomic, strong) CLLocation                    *currentLocation;
@property (nonatomic, strong) CLLocation                    *USERDEFHomeLocation;  //spot for "ddirect distance fron start" odometer
@property (nonatomic, strong) WeatherService                *weatherService;
@property (nonatomic, strong) Spectrum                      *colors;

@property (nonatomic, copy) NSString                        *LEDFont;
@property (nonatomic, copy) NSString                        *LabelFont;
@property (nonatomic, copy) NSString                        *SansFont;
@property (nonatomic, copy) NSString                        *SansItalic;

@property (nonatomic, copy) UIColor                         *defaultLabelColor;
@property (nonatomic, copy) UIColor                         *defaultSpeedColor;
@property (nonatomic, copy) UIColor                         *speedWarningColor;

@property (nonatomic, copy) NSString                        *appVersionNumber;
@property (nonatomic, copy) NSString                        *appBuildNumber;

@property (nonatomic, copy)                                 NSMutableString *lastLocationName;

@property (nonatomic) BOOL                                  USERDEFdropPinForWeatherStations;
@property (nonatomic) int                                   USERDEFweatherUpdatePeriod; // 0 to 3. 0: never. 1: 1 min. 2, 5 min. 3: 10 min.
@property (nonatomic) BOOL                                  USERDEFdisplayTemperatureInColor;

@property (nonatomic) double                                currentMetersPerSecond;
@property (nonatomic) double                                currentTemperature;
@property (nonatomic) double                                currentAltitude;

@property (nonatomic) double                                USERDEFspeedLimit;      // in meters per second
@property (nonatomic) bool                                  USERDEFplaySoundOnSpeedWarning;
@property (nonatomic) bool                                  aboveSpeedThresholdFlag;
@property (nonatomic) int                                   speedWarningBeepTimeBuffer;
@property (nonatomic, copy) NSDate                          *lastSpeedWarningBeepDate;

@property (nonatomic) int                                   USERDEFtripOdometerSelected;

@property (nonatomic) double                                headingAccuracy;            // degress that must change before be notified

@property (nonatomic) double                                odometerAccuracy;           // meters.
@property (nonatomic) double                                odometerTripA;              // meters.
@property (nonatomic) double                                odometerTripB;              // meters.

@property (nonatomic) int                                   USERDEFDistanceUnits;       //0 mph, 1 kmh, 2 knots
@property (nonatomic) int                                   USERDEFTemperatureUnits;      //0 fahrenheit, 1 celsius

@property (nonatomic, copy) NSArray                         *UNITS_SPEED;
@property (nonatomic, copy) NSArray                         *UNITS_DISTANCE;
@property (nonatomic, copy) NSArray                         *UNITS_TEMP;

@property (nonatomic) double                                mapViewZoomLevelLat;
@property (nonatomic) double                                mapViewZoomLevelLon;

@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"View did load: MainViewController");
    
    
    _BOOGEYMODE                         = false;
    _BOOGEYSPEED                        = 29.77286;
    
    _LEDFont                            = @"Digital-7";
    _LabelFont                          = @"Highway Gothic Narrow";
    _SansFont                           = @"Helvetica";
    _SansItalic                         = @"Helvetica-Italic";
    
    _UNITS_SPEED                        = @[@"MPH", @"KPH", @"Knots"];
    _UNITS_DISTANCE                     = @[@"Mi", @"K", @"NM"];
    _UNITS_TEMP                         = @[@"F", @"C"];
    
    
    _lastLocationName                   = [[NSMutableString alloc] init];
    
    
    _aboveSpeedThresholdFlag            = false;
    _lastSpeedWarningBeepDate           = [NSDate date];
    _speedWarningBeepTimeBuffer         = 10;           // must wait ten seconds before beeping again.
    
    _odometerAccuracy                   = 5.000;        // must move n meters before adding to odometer variables.
    _headingAccuracy                    = 3.000;
    
    _appVersionNumber                   = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _appBuildNumber                     = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    _currentLocation                    = nil;
    
    _MapView.showsTraffic               = true;
    _MapView.showsScale                 = true;
    
    [self initLocationManager];
    [self initColorChart];
    
    [self cleanInterface];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"View did load: MainViewController");
    [self loadPrefernces];
}

- (void)loadPrefernces
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults doubleForKey:@"odometerTripA"]) {
        _odometerTripA = [defaults doubleForKey:@"odometerTripA"];
    } else {
        _odometerTripA = 0.0;
    }
    
    if ([defaults doubleForKey:@"odometerTripB"]) {
        _odometerTripB = [defaults doubleForKey:@"odometerTripB"];
    } else {
        _odometerTripB = 0.0;
    }
    
    if ([defaults stringForKey:@"lastLocationName"]) {
        [_lastLocationName setString:[defaults stringForKey:@"lastLocationName"]];
    }
    
    
    if ([defaults doubleForKey:@"mapViewZoomLevelLat"]) {
        _mapViewZoomLevelLat = (double)[defaults doubleForKey:@"mapViewZoomLevelLat"];
    } else {
        _mapViewZoomLevelLat = 42.2814;
    }
    
    if ([defaults doubleForKey:@"mapViewZoomLevelLon"]) {
        _mapViewZoomLevelLon = (double)[defaults doubleForKey:@"mapViewZoomLevelLon"];
    } else {
        _mapViewZoomLevelLon = -83.7483;
    }
    
    if ([defaults doubleForKey:@"currentTemperature"]) {
        _currentTemperature = (double)[defaults doubleForKey:@"currentTemperature"];
    } else {
        _currentTemperature = -9999.00;
    }
    
    if ([defaults doubleForKey:@"currentAltitude"]) {
        _currentAltitude = (double)[defaults doubleForKey:@"currentAltitude"];
    } else {
        _currentAltitude = 0.000;
    }
    
    if ([defaults integerForKey:@"USERDEFtripOdometerSelected"]) {
        _USERDEFtripOdometerSelected = (int)[defaults integerForKey:@"USERDEFtripOdometerSelected"];
    } else {
        _USERDEFtripOdometerSelected = 0;
    }
    
    if ([defaults boolForKey:@"USERDEFdropPinForWeatherStations"]) {
        _USERDEFdropPinForWeatherStations = (bool)[defaults boolForKey:@"USERDEFdropPinForWeatherStations"];
    } else {
        _USERDEFdropPinForWeatherStations = false;
    }
    
    if ([defaults integerForKey:@"USERDEFweatherUpdatePeriod"]) {
        _USERDEFweatherUpdatePeriod = (int)[defaults integerForKey:@"USERDEFweatherUpdatePeriod"];
        if (_USERDEFweatherUpdatePeriod > 3) {_USERDEFweatherUpdatePeriod = 3;}
    } else {
        _USERDEFweatherUpdatePeriod = 3;
    }
    
    if ([defaults boolForKey:@"USERDEFplaySoundOnSpeedWarning"]) {
        _USERDEFplaySoundOnSpeedWarning = (bool)[defaults boolForKey:@"USERDEFplaySoundOnSpeedWarning"];
    } else {
        _USERDEFplaySoundOnSpeedWarning = false;
    }
    
    //NSLog(@"loading: _USERDEFplaySoundOnSpeedWarning = %d", _USERDEFplaySoundOnSpeedWarning);
    
    if ([defaults doubleForKey:@"USERDEFspeedLimit"]) {
        _USERDEFspeedLimit = (double)[defaults doubleForKey:@"USERDEFspeedLimit"];
    } else {
        _USERDEFspeedLimit = [self convertSpeedToMetersPerSecond:90.000];
    }
    
    //NSLog(@"loading: _USERDEFspeedLimit = %f (%d)", _USERDEFspeedLimit, (int)(round([self convertMetersPerSecondToSpeed:_USERDEFspeedLimit])));
    
    if ([defaults integerForKey:@"USERDEFDistanceUnits"]) {
        _USERDEFDistanceUnits = (int)[defaults integerForKey:@"USERDEFDistanceUnits"];
    } else {
        _USERDEFDistanceUnits = 0;
    }
    
    if ([defaults integerForKey:@"USERDEFTemperatureUnits"]) {
        _USERDEFTemperatureUnits = (int)[defaults integerForKey:@"USERDEFTemperatureUnits"];
    } else {
        _USERDEFTemperatureUnits = 0;
    }
    
    if ([defaults boolForKey:@"USERDEFdisplayTemperatureInColor"]) {
        _USERDEFdisplayTemperatureInColor = [defaults boolForKey:@"USERDEFdisplayTemperatureInColor"];
    } else {
        _USERDEFdisplayTemperatureInColor = false;
    }
    
    if ([defaults objectForKey:@"USERDEFHomeLocation"]) {
        NSDictionary *userLoc=[defaults objectForKey:@"USERDEFHomeLocation"];
        _USERDEFHomeLocation = [[CLLocation alloc] initWithLatitude:[[userLoc objectForKey:@"lat"] doubleValue] longitude:[[userLoc objectForKey:@"long"] doubleValue]];
    } else {
        _USERDEFHomeLocation = nil;
    }
    
}

- (void)savePreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setDouble:_odometerTripA forKey:@"odometerTripA"];
    [defaults setDouble:_odometerTripB forKey:@"odometerTripB"];
    [defaults setInteger:_USERDEFDistanceUnits forKey:@"USERDEFDistanceUnits"];
    [defaults setInteger:_USERDEFTemperatureUnits forKey:@"USERDEFTemperatureUnits"];
    [defaults setBool:_USERDEFdisplayTemperatureInColor forKey:@"USERDEFdisplayTemperatureInColor"];
    [defaults setDouble:[self mapViewZoomLevelLatitude] forKey:@"mapViewZoomLevelLat"];
    [defaults setDouble:[self mapViewZoomLevelLongitude] forKey:@"mapViewZoomLevelLon"];
    [defaults setDouble:_currentTemperature forKey:@"currentTemperature"];
    [defaults setDouble:_currentAltitude forKey:@"currentAltitude"];
    [defaults setInteger:_USERDEFweatherUpdatePeriod forKey:@"USERDEFweatherUpdatePeriod"];
    [defaults setBool:_USERDEFplaySoundOnSpeedWarning forKey:@"USERDEFplaySoundOnSpeedWarning"];
    [defaults setDouble:_USERDEFspeedLimit forKey:@"USERDEFspeedLimit"];
    [defaults setInteger:_USERDEFtripOdometerSelected forKey:@"USERDEFtripOdometerSelected"];
    
    NSNumber *lat = [NSNumber numberWithDouble:_USERDEFHomeLocation.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:_USERDEFHomeLocation.coordinate.longitude];
    NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
    [defaults setObject:userLocation forKey:@"USERDEFHomeLocation"];
    
    [defaults synchronize];
}


- (void)initLocationManager
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //_locationManager.distanceFilter  = kCLLocationAccuracyNearestTenMeters;
    [_locationManager requestWhenInUseAuthorization];
}


- (void)initWeatherService
{
    if (_USERDEFweatherUpdatePeriod <= 6 && _USERDEFweatherUpdatePeriod > 0) {
        
    } else {
        _USERDEFweatherUpdatePeriod = 6;
    }
    double period = [self weatherRefreshTimeInSeconds];
    _weatherService = [[WeatherService alloc] initWithDelegate:self
                                                      location:_locationManager.location
                                                updateInterval:period
                                                   autoUpdates:YES
                                              beginDownloading:YES];
}

- (void)initColorChart
{
    _colors = [[Spectrum alloc] init];
    _defaultLabelColor      = _colors.GoldenRod;
    _defaultSpeedColor      = _colors.LEDGreen;
    _speedWarningColor      = _colors.Crimson;
    _WeatherSpinner.color   = _defaultLabelColor;
}

- (void)cleanInterface
{
    
    [self setSpeedButtonLabel:0.0];
    [self setAltitudeButtonLabel:_currentAltitude];
    [self setHeadingButtonLabel:0];
    [self setOdometerButtonLabel:_odometerTripA metersB:_odometerTripB];
    [self setDirectDistanceButtonLabel:0.0];
    [self setTempButtonLabel:_currentTemperature];
    [_LocationButton setTitle:@"" forState:UIControlStateNormal];
    _SunLabel.text = @"";
    [self setClockButtonLabel];
    [self setSunLabel];
}





#pragma mark View Controller methods

- (IBAction)OpenPreferencesView:(id)sender {
    [self savePreferences];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UIViewController *viewController =
    [[UIStoryboard storyboardWithName:@"Main"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"PreferencesViewController"];
    
    [self presentViewController:viewController animated:YES completion:nil];
}


- (IBAction)CenterMapButtonClicked:(id)sender {
    [self centerMapView:[self mapViewZoomLevelLatitude] longitudeSpan:[self mapViewZoomLevelLatitude]];
    [self savePreferences];
}


- (IBAction)SpeedButtonClicked:(id)sender forEvent:(UIEvent *)event {
    [self toggleSpeedUnitsState];
    [self setSpeedButtonLabel:_currentMetersPerSecond];
    [self setOdometerButtonLabel:_odometerTripA metersB:_odometerTripB];
    
    if ( _USERDEFHomeLocation != nil) {
        CLLocationDistance directDistance = [_currentLocation distanceFromLocation:_USERDEFHomeLocation];
        [self setDirectDistanceButtonLabel:directDistance];
    }
    [self savePreferences];
}

- (IBAction)TemperatureButtonClicked:(id)sender {
    [self toggleUSERDEFTemperatureUnits];
    [self getCurrentTemperature];
    [self savePreferences];
}

- (IBAction)TripButtonClicked:(id)sender {
    [self toggleOdometerViewState];
    [self setOdometerButtonLabel:_odometerTripA metersB:_odometerTripB];
    [self savePreferences];
}

- (IBAction)OdomterButtonClicked:(id)sender {
    
    NSString *label;
    
    switch(_USERDEFtripOdometerSelected) {
        case 0: default:
            label = @"Do you want to reset Trip A to zero? This cannot be undone...";
            break;
        case 1:
            label = @"Do you want to reset Trip B to zero? This cannot be undone...";
            break;
    }
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"Reset Trip Odometer:"
                                                                               message:label
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesbutton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    if (_USERDEFtripOdometerSelected == 0) {
                                        _odometerTripA = 0.0;
                                    } else {
                                        _odometerTripB = 0.0;
                                    }
                                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                }];
    UIAlertAction *nobutton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [myAlertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [myAlertController addAction: yesbutton];
    [myAlertController addAction: nobutton];
    [self presentViewController:myAlertController animated:YES completion:nil];
    
    [self setOdometerButtonLabel:_odometerTripA metersB:_odometerTripB];
    [self savePreferences];
}

- (IBAction)DirectDistanceButttonClicked:(id)sender {
    
    CLLocation *frobble;
    if (_currentLocation != nil) {
        frobble = [_currentLocation copy];
    } else {
        frobble = [_locationManager.location copy];
    }
    
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"Set Home Location"
                                                                               message: @"Do you want to make the current location your home location? This cannot be undone."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesbutton = [UIAlertAction
                                actionWithTitle:@"Yep"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    _USERDEFHomeLocation = frobble;
                                    
                                    CLLocationDistance directDistance = [_locationManager.location distanceFromLocation:_USERDEFHomeLocation];
                                    
                                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                    [annotation setCoordinate:CLLocationCoordinate2DMake(_USERDEFHomeLocation.coordinate.latitude,_USERDEFHomeLocation.coordinate.longitude)];
                                    [annotation setTitle:@"N-Dash Starting Point"];
                                    
                                    [self.MapView addAnnotation:annotation];
                                    [self setDirectDistanceButtonLabel:directDistance];
                                    [self savePreferences];
                                    
                                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    UIAlertAction *nobutton = [UIAlertAction
                               actionWithTitle:@"Nah"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [myAlertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [myAlertController addAction: yesbutton];
    [myAlertController addAction: nobutton];
    [self presentViewController:myAlertController animated:YES completion:nil];
    
}


#pragma mark Map View methods

- (void)centerMapView:(double)zoomLevelLat longitudeSpan:(double)zoomLevelLon
{
    [_MapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
}

- (double)mapViewZoomLevelLatitude
{
    if (_MapView != nil) {
        MKCoordinateRegion mregion;
        mregion = [_MapView region];
        return mregion.span.latitudeDelta;
    } else {
        return _mapViewZoomLevelLat;
    }
}

- (double)mapViewZoomLevelLongitude
{
    if (_MapView != nil) {
        MKCoordinateRegion mregion;
        mregion = [_MapView region];
        return mregion.span.longitudeDelta;
    } else {
        return _mapViewZoomLevelLon;
    }
}







#pragma mark Weather Info methods
- (void)getCurrentTemperature
{
    // weatherservice auto updates via delegate method, so no sense calling this method anymore
    if (_weatherService) {
        _currentTemperature = _weatherService.celsius;
        [self setTempButtonLabel:_currentTemperature];
    }
}

- (double)weatherRefreshTimeInSeconds
{
    double seconds;
    switch ((_USERDEFweatherUpdatePeriod)) {
            
        case 0: // never!
            seconds = 0.000;
            break;
            
        case 1: default: // 1 min
            seconds = 60.000;
            break;
            
        case 2: // 5 min
            seconds = 300.000;
            break;
            
        case 3: // 10 min
            seconds = 600.000;
            break;
            
        case 4: // 10 seconds, hidden feature.
            seconds = 30.000;
            break;
    }
    return seconds;
}




#pragma mark UI Button Label Setting Methods
- (void)setSpeedButtonLabel:(double)mps
{
    double speed = [self convertMetersPerSecondToSpeed:mps];
    UIColor *unitColor;
    
    NSLog(@"_USERDEFplaySoundOnSpeedWarning = %d, _USERDEFspeedLimit = %f (%d)",
            _USERDEFplaySoundOnSpeedWarning,
            _USERDEFspeedLimit,
            (int)(round([self convertMetersPerSecondToSpeed:_USERDEFspeedLimit])));
    
    if (_USERDEFplaySoundOnSpeedWarning == YES) {
        if (mps >= _USERDEFspeedLimit) {
            [self playSpeedWarningSound];
            unitColor = _speedWarningColor;
            //NSLog(@"_USERDEFplaySoundOnSpeedWarning = %d", _USERDEFplaySoundOnSpeedWarning);
            //NSLog(@"_USERDEFspeedLimit = %f (%d)", _USERDEFspeedLimit,(int)(round([self convertMetersPerSecondToSpeed:_USERDEFspeedLimit])));
        } else {
            unitColor = _defaultSpeedColor;
        }
    } else {
        unitColor = _defaultSpeedColor;
    }
    
    if (speed < 0)  speed = 0;
    if (_BOOGEYMODE) speed = [self convertMetersPerSecondToSpeed:_BOOGEYSPEED];
    
    NSArray *si = [[NSString stringWithFormat:@"%.1f", speed] componentsSeparatedByString:@"."];
    
    NSMutableAttributedString *speedLeft = [[NSMutableAttributedString alloc] initWithString:si[0]];
    [speedLeft addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LEDFont size:140] range:NSMakeRange(0,[speedLeft length])];
    [speedLeft addAttribute:NSForegroundColorAttributeName value:unitColor range:NSMakeRange(0,[speedLeft length])];
    [_SpeedButton setAttributedTitle:speedLeft forState:UIControlStateNormal];
    _SpeedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    
    NSMutableAttributedString *fractionString = [[NSMutableAttributedString alloc] initWithString:@"."];
    [fractionString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:22] range:NSMakeRange(0,[fractionString length])];
    [fractionString addAttribute:NSForegroundColorAttributeName value:unitColor range:NSMakeRange(0,[fractionString length])];
    
    NSMutableAttributedString *speedRight = [[NSMutableAttributedString alloc] initWithString:si[1]];
    [speedRight addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LEDFont size:72] range:NSMakeRange(0,[speedRight length])];
    [speedRight addAttribute:NSForegroundColorAttributeName value:unitColor range:NSMakeRange(0,[speedRight length])];
    
    [fractionString appendAttributedString:speedRight];
    _SpeedFractionLabel.attributedText = fractionString;
    
    
    NSMutableAttributedString *unitString = [[NSMutableAttributedString alloc] initWithString:_UNITS_SPEED[_USERDEFDistanceUnits]];
    [unitString addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:24] range:NSMakeRange(0,[unitString length])];
    [unitString addAttribute:NSForegroundColorAttributeName value:unitColor range:NSMakeRange(0,[unitString length])];
    
    _SpeedUnitsLabel.attributedText = unitString;
    
}

-(void)setClockButtonLabel {
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    NSString *clockString = [NSString stringWithFormat:@"%@",dateString];
    NSMutableAttributedString *clockText = [[NSMutableAttributedString alloc] initWithString:clockString];
    [clockText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:44] range:NSMakeRange(0,[clockText length])];
    [clockText addAttribute:NSForegroundColorAttributeName value:_defaultLabelColor range:NSMakeRange(0,[clockText length])];
    [_ClockButton setAttributedTitle:clockText forState:UIControlStateNormal];
    _ClockButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)setTempButtonLabel:(double)celsius
{
    int degrees = (int)(round([self temperatureForcelsius:celsius]));
    UIColor *tempcolor;
    NSMutableString *tempString;
    NSMutableAttributedString *tempText;
    
    //NSLog(@"Setting temp: %d",degrees);
    
    if (_USERDEFdisplayTemperatureInColor) {
        tempcolor = [self colorForTemperatureInFahrenheit:[self celsiusToFahrenheit:celsius]];
    } else {
        tempcolor = _defaultLabelColor;
    }
    
    if (degrees < -999) {
        tempString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"--º%@", _UNITS_TEMP[_USERDEFTemperatureUnits]]];
        tempText = [[NSMutableAttributedString alloc] initWithString:tempString];
        [tempText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:44] range:[tempString rangeOfString:@"--º"]];
        [tempText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:32] range:[tempString rangeOfString:_UNITS_TEMP[_USERDEFTemperatureUnits]]];
        [tempText addAttribute:NSForegroundColorAttributeName value:tempcolor range:NSMakeRange(0,[tempString length])];
    } else {
        tempString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%dº%@", degrees, _UNITS_TEMP[_USERDEFTemperatureUnits]]];
        tempText = [[NSMutableAttributedString alloc] initWithString:tempString];
        [tempText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:44] range:[tempString rangeOfString:[NSString stringWithFormat:@"%d", degrees]]];
        [tempText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:32] range:[tempString rangeOfString:_UNITS_TEMP[_USERDEFTemperatureUnits]]];
        [tempText addAttribute:NSForegroundColorAttributeName value:tempcolor range:NSMakeRange(0,[tempString length])];
    }
    [_TempButton setAttributedTitle:tempText forState:UIControlStateNormal];
    _TempButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

- (void)setAltitudeButtonLabel:(double)meters
{
    NSString *units;
    NSMutableString *altString;
    NSMutableAttributedString *altText;
    int altitude = 0;
    
    switch (_USERDEFDistanceUnits)
    {
        case 0: default://feet
            altitude = (int)(round(meters * 3.28084));
            units = @"'";
            break;
        case 1: // meters
            altitude = (int)(round(meters));
            units = @"m";
            break;
    }
    
    if (altitude < -500) {
        altString = [[NSMutableString alloc] initWithString:@"---"];
        altText = [[NSMutableAttributedString alloc] initWithString:altString];
        [altText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:28] range:NSMakeRange(0,[altString length])];
        [altText addAttribute:NSForegroundColorAttributeName value:_defaultLabelColor range:NSMakeRange(0,[altString length])];
    } else {
        altString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"Altitude: %d%@", altitude, units]];
        altText = [[NSMutableAttributedString alloc] initWithString:altString];
        [altText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:28] range:NSMakeRange(0,[altString length])];
        [altText addAttribute:NSForegroundColorAttributeName value:_defaultLabelColor range:NSMakeRange(0,[altString length])];
    }
    [_AltitudeButton setAttributedTitle:altText forState:UIControlStateNormal];
    _AltitudeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

- (void)setHeadingButtonLabel:(int)heading
{
    NSString *direction;
    NSMutableString *headString;
    NSMutableAttributedString *headText;
    
    if (heading > 380.0001) {
        direction = @"";
        headString = [[NSMutableString alloc] initWithString:@"..."];
        headText = [[NSMutableAttributedString alloc] initWithString:headString];
        [headText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LEDFont size:28] range:NSMakeRange(0,[headString length])];
        [headText addAttribute:NSForegroundColorAttributeName value:_defaultLabelColor range:NSMakeRange(0,[headString length])];
    } else {
        direction = [self directionForHeading:heading];
        headString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%dº %@", heading, direction]];
        headText = [[NSMutableAttributedString alloc] initWithString:headString];
        [headText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:28] range:NSMakeRange(0,[headString length])];
        [headText addAttribute:NSForegroundColorAttributeName value:_defaultLabelColor range:NSMakeRange(0,[headString length])];
    }
    [_HeadingButton setAttributedTitle:headText forState:UIControlStateNormal];
    _HeadingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)setOdometerButtonLabel:(double)metersA metersB:(double)metersB
{
    
    NSString    *tripLetter;
    double      meters;
    
    switch(_USERDEFtripOdometerSelected)
    {
        case 0: default:
            tripLetter = @"Trip A";
            meters     = metersA;
            break;
        case 1:
            tripLetter = @"Trip B";
            meters     = metersB;
            break;
    }
    
    double distance = [self convertMetersToDistance:meters];
    
    
    if (distance < 0.000001) distance = 0.000001;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    UIFont *labelFont = [UIFont fontWithName:_LabelFont size:24];
    NSAttributedString *tripLabelText = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@",tripLetter]
                                                                        attributes: @{NSParagraphStyleAttributeName :paragraphStyle,
                                                                                      NSFontAttributeName: labelFont,
                                                                                      NSForegroundColorAttributeName: _defaultLabelColor}];
    [_OdometerLabel setAttributedTitle:tripLabelText forState:UIControlStateNormal];
    _OdometerLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    NSMutableString *odoString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%.01f %@", distance, _UNITS_DISTANCE[_USERDEFDistanceUnits]]];
    NSMutableAttributedString *odoText = [[NSMutableAttributedString alloc] initWithString:odoString];
    [odoText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:28] range:[odoString rangeOfString:[NSString stringWithFormat:@"%.01f", distance]]];
    [odoText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:18] range:[odoString rangeOfString:_UNITS_DISTANCE[_USERDEFDistanceUnits]]];
    [odoText addAttribute:NSForegroundColorAttributeName value:_defaultLabelColor range:NSMakeRange(0,[odoString length])];
    
    [_OdometerButton setAttributedTitle:odoText forState:UIControlStateNormal];
    _OdometerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)setDirectDistanceButtonLabel:(double)meters
{
    double       distance   = [self convertMetersToDistance:meters];
    
    if (distance < 0.000001) distance = 0.000001;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    UIFont *labelFont = [UIFont fontWithName:_LabelFont size:24];
    NSAttributedString *labelText = [[NSAttributedString alloc] initWithString:@"Distance:"
                                                                    attributes: @{NSParagraphStyleAttributeName :paragraphStyle,
                                                                                  NSFontAttributeName: labelFont,
                                                                                  NSForegroundColorAttributeName: _defaultLabelColor}];
    
    _DirectDistanceLabel.attributedText = labelText;
    
    NSMutableString *ddString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%.01f %@", distance, _UNITS_DISTANCE[_USERDEFDistanceUnits]]];
    NSMutableAttributedString *ddText = [[NSMutableAttributedString alloc] initWithString:ddString];
    [ddText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:28] range:[ddString rangeOfString:[NSString stringWithFormat:@"%.01f", distance]]];
    [ddText addAttribute:NSFontAttributeName value:[UIFont fontWithName:_LabelFont size:18] range:[ddString rangeOfString:_UNITS_DISTANCE[_USERDEFDistanceUnits]]];
    [ddText addAttribute:NSForegroundColorAttributeName value:_defaultLabelColor range:NSMakeRange(0,[ddString length])];
    
    [_DirectDistanceButton setAttributedTitle:ddText forState:UIControlStateNormal];
    _DirectDistanceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)setLocationButtonLabel:(NSString *)location
{
    if ([location isEqualToString:@"..."] || [location caseInsensitiveCompare:@"Earth"] == NSOrderedSame) {
        [_LocationButton setTitle:@"Searching..." forState:UIControlStateNormal];
    } else if (![_lastLocationName isEqualToString:location]) {
        _lastLocationName = nil;
        _lastLocationName = [[NSMutableString alloc] initWithString:location];
        if ([location length] >= 32) {
            [_LocationButton setTitle:[NSString stringWithFormat:@"%@",[location substringToIndex:17]] forState:UIControlStateNormal];
        } else {
            [_LocationButton setTitle:[NSString stringWithFormat:@"%@",location] forState:UIControlStateNormal];
        }
    }
}

- (void)setSunLabel
{
    NSDate *today = [NSDate date];
    
    EDSunriseSet *ssettoday = [[EDSunriseSet alloc] initWithDate:today timezone:[NSTimeZone systemTimeZone]
                                                        latitude:_currentLocation.coordinate.latitude
                                                       longitude:_currentLocation.coordinate.longitude];
    EDSunriseSet *ssettomorrow = [[EDSunriseSet alloc] initWithDate:[today dateByAddingTimeInterval:60*60*24] timezone:[NSTimeZone systemTimeZone]
                                                           latitude:_currentLocation.coordinate.latitude
                                                          longitude:_currentLocation.coordinate.longitude];
    
    if ([ssettoday sunrise] != nil) {
        if ([[NSDate date] timeIntervalSinceDate:[ssettoday sunset]] <= 0 && [[NSDate date] timeIntervalSinceDate:[ssettoday sunrise]] > 0) {
            // after sunrise but before sunset
            _SunLabel.text = [NSString stringWithFormat:@"%@ until sunset (%@)",
                              [self timeUntilDateFormatted:[ssettoday sunset]],
                              [self formattedStringFromDate:[ssettoday sunset]]];
        } else if ([[NSDate date] timeIntervalSinceDate:[ssettoday sunrise]] > 0 && [[NSDate date] timeIntervalSinceDate:[ssettoday sunset]] > 0) {
            // after sunrise and after sunset, so point to sunrise tomorrow.
            _SunLabel.text = [NSString stringWithFormat:@"%@ until sunrise (%@)",
                              [self timeUntilDateFormatted:[ssettomorrow sunrise]],
                              [self formattedStringFromDate:[ssettomorrow sunrise]]];
        } else {
            // sunrise today.
            _SunLabel.text = [NSString stringWithFormat:@"%@ until sunrise (%@)",
                              [self timeUntilDateFormatted:[ssettoday sunrise]],
                              [self formattedStringFromDate:[ssettoday sunrise]]];
        }
    } else {
        _SunLabel.text = @"";
    }
}




#pragma mark Misc functions

- (void)playSpeedWarningSound
{
    if ([self secondsSinceDate:_lastSpeedWarningBeepDate] >= _speedWarningBeepTimeBuffer) {
        _lastSpeedWarningBeepDate = [NSDate date];
        [self playSound:@"warning" :@"wav"];
    }
}

- (int)hoursSinceDate :(NSDate *)date
{
    NSDate *currentTime = [NSDate date];
    double secondsSinceDate = [currentTime timeIntervalSinceDate:date];
    return (int)secondsSinceDate / 3600;
}

- (int)minutesSinceDate :(NSDate *)date
{
    NSDate *currentTime = [NSDate date];
    double secondsSinceDate = [currentTime timeIntervalSinceDate:date];
    return (int)secondsSinceDate / 60;
}

- (int)secondsSinceDate :(NSDate *)date
{
    
    NSDate *currentTime = [NSDate date];
    double secondsSinceDate = [currentTime timeIntervalSinceDate:date];
    return (int)secondsSinceDate;
}

- (void)playSound:(NSString *)fName :(NSString *)ext
{
    SystemSoundID audioEffect;
    NSString *path = [[NSBundle mainBundle] pathForResource : fName ofType :ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path]) {
        NSURL *pathURL = [NSURL fileURLWithPath: path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
}

- (NSString *)directionForHeading:(int)heading
{
    NSString *direction;
    switch (heading)
    {
        case 349 ... 360:
            direction = @"N";
            break;
            
        case 0 ... 10:
            direction = @"N";
            break;
            
        case 11 ... 33:
            direction = @"NNE";
            break;
            
        case 34 ... 55:
            direction = @"NE";
            break;
            
        case 56 ... 78:
            direction = @"ENE";
            break;
            
        case 79 ... 100:
            direction = @"E";
            break;
            
        case 101 ... 123:
            direction = @"ESE";
            break;
            
        case 124 ... 145:
            direction = @"SE";
            break;
            
        case 146 ... 168:
            direction = @"SSE";
            break;
            
        case 169 ... 190:
            direction = @"S";
            break;
            
        case 191 ... 213:
            direction = @"SSW";
            break;
            
        case 214 ... 235:
            direction = @"SW";
            break;
            
        case 236 ... 258:
            direction = @"WSW";
            break;
            
        case 259 ... 280:
            direction = @"W";
            break;
            
        case 281 ... 303:
            direction = @"WNW";
            break;
            
        case 304 ... 325:
            direction = @"NW";
            break;
            
        case 326 ... 348:
            direction = @"NNW";
            break;
            
        default:
            direction = @"";
            break;
            
    }
    return direction;
}


#pragma mark Toggle UI display units
- (void)toggleSpeedUnitsState
{
    switch (_USERDEFDistanceUnits)
    {
        case 0: default:// MPH
            _USERDEFDistanceUnits = 1; // now KPH
            break;
        case 1: // KPH
            _USERDEFDistanceUnits = 2; // now Feet per second (FPS)
            break;
        case 2: // Knots
            _USERDEFDistanceUnits = 0; // now Knots per hour
            break;
            
    }
}

- (void)toggleUSERDEFTemperatureUnits
{
    switch (_USERDEFTemperatureUnits)
    {
        case 0: default:// Fahrenheit
            _USERDEFTemperatureUnits = 1; // now celsius
            break;
        case 1: // celsius
            _USERDEFTemperatureUnits = 0; // now back to Fahrenheit
            break;
    }
}

- (void)toggleOdometerViewState
{
    switch (_USERDEFtripOdometerSelected)
    {
        case 0: default:// Trip A
            _USERDEFtripOdometerSelected = 1; // now tripb
            break;
        case 1: // Trip B
            _USERDEFtripOdometerSelected = 0; // now tripA
            break;
    }
}

-(UIColor *)colorForTemperatureInFahrenheit:(int)temp
{
    // fahrenheit because im an american. sigh. fucking shitty ass public education system. thanks, republicans.
    
    UIColor *tempColor;
    switch (temp)
    {
        case -50 ... -20:
            tempColor = _colors.PurpleMedium;
            break;
            
        case -19 ... 0:
            tempColor = _colors.PurpleLight;
            break;
            
        case 1 ... 20:
            tempColor = _colors.BlueMedium;
            break;
            
        case 21 ... 39:
            tempColor = _colors.BlueLight;
            break;
            
        case 40 ... 50:
            tempColor = _colors.GreenMedium;
            break;
            
        case 51 ... 60:
            tempColor = _colors.GreenLight;
            break;
            
        case 61 ... 70:
            tempColor = _colors.YellowGreen;
            break;
            
        case 71 ... 80:
            tempColor = _colors.YellowDark;
            break;
            
        case 81 ... 90:
            tempColor = _colors.OrangeLight;
            break;
            
        case 91 ... 100:
            tempColor = _colors.OrangeMedium;
            break;
            
        case 101 ... 110:
            tempColor = _colors.RedMedium;
            break;
            
        case 111 ... 500:
            tempColor = _colors.RedDark;
            break;
            
        default:
            tempColor = _defaultLabelColor;
            break;
    }
    return tempColor;
}

- (UIColor *)colorForSpeed:(double)mps
{
    UIColor *speedColor;
    int speed = round(mps);
    switch (speed)
    {
        case 0 ... 10:
            speedColor = _colors.GreenMedium;
            break;
            
        case 11 ... 20:
            speedColor = _colors.GreenMedium;
            break;
            
        case 21 ... 30:
            speedColor = _colors.GreenMedium;
            break;
            
        case 31 ... 40:
            speedColor = _colors.YellowMedium;
            break;
            
        case 41 ... 50:
            speedColor = _colors.YellowMedium;
            break;
            
        case 51 ... 60:
            speedColor = _colors.YellowMedium;
            break;
            
        case 61 ... 70:
            speedColor = _colors.OrangeMedium;
            break;
            
        case 71 ... 80:
            speedColor = _colors.OrangeMedium;
            break;
            
        case 81 ... 90:
            speedColor = _colors.RedMedium;
            break;
            
        case 91 ... 200:
            speedColor = _colors.RedMedium;
            break;
            
        default:
            speedColor = _colors.GreenLight;
            break;
    }
    return speedColor;
}

- (NSString *)formattedStringFromDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"h:mm a"];
    return [format stringFromDate:date];
}

- (NSString *)timeUntilDateFormatted:(NSDate *)date
{
    if (date != nil) {
        NSTimeInterval tt = [date timeIntervalSinceNow];
        return [self stringFromTimeInterval:tt];
    } else {
        return nil;
    }
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    if (hours > 0) {
        return [NSString stringWithFormat:@"%ldh %ldm", (long)hours, (long)minutes];
    } else {
        return [NSString stringWithFormat:@"%ldm", (long)minutes];
    }
}

- (double)temperatureForcelsius:(double)celsius
{
    double temp;
    switch (_USERDEFTemperatureUnits) {
        case 0: default: //fahrenheit
            temp = [self celsiusToFahrenheit:celsius];
            break;
        case 1:
            temp = celsius;
            break;
    }
    return temp;
}

- (double)celsiusToFahrenheit:(double)celsius
{
    return ((double)celsius * 9.0/5.0 + 32.0);
}

- (double)fahrenheitTocelsius:(double)fahrenheit
{
    return ((double)5.0/9.0) * (fahrenheit-32);
}


-(double)convertMetersPerSecondToSpeed:(double)mps
{
    double speed;
    switch(_USERDEFDistanceUnits) {
        case 0: default: //mph
            speed = [self metersPerSecondToMilesPerHour:(mps)];
            break;
        case 1: //kph
            speed = [self metersPerSecondToKilometersPerHour:(mps)];
            break;
        case 2: //knots
            speed = [self metersPerSecondToKnots:(mps)];
            break;
    }
    return speed;
}

-(double)convertSpeedToMetersPerSecond:(double)speed
{
    double mps;
    switch(_USERDEFDistanceUnits) {
        case 0: default: //mph
            mps = [self milesPerHourToMetersPerSecond:(speed)];
            break;
        case 1: //kph
            mps = [self kilometersPerHourToMetersPerSecond:(speed)];
            break;
        case 2: //knots
            mps = [self knotsToMetersPerSecond:(speed)];
            break;
    }
    return mps;
}

- (double)convertMetersToDistance:(double)meters
{
    double distance;
    switch(_USERDEFDistanceUnits) {
        case 0: default: //miles, mph
            distance = [self metersToMiles:(meters)];
            break;
        case 1: //kph
            distance = [self metersToKilometers:(meters)];
            break;
        case 2: //knots
            distance = [self metersToNauticalMiles:(meters)];
            break;
    }
    return distance;
}

- (double)convertDistanceToMeters:(double)distance
{
    double meters;
    switch(_USERDEFDistanceUnits) {
        case 0: default: //miles, mph
            meters = [self milesToMeters:(distance)];
            break;
        case 1: //kph
            meters = [self kilometersToMeters:(distance)];
            break;
        case 2: //knots
            meters = [self nauticalMilesToMeters:(distance)];
            break;
    }
    return meters;
}

- (double)metersPerSecondToMilesPerHour:(double)mps
{
    return (double)(mps * 2.23693629);
}

-(double)metersPerSecondToKilometersPerHour:(double)mps
{
    return (double)(mps * 3.6);
}

-(double)metersPerSecondToKnots:(double)mps
{
    return (double)(mps * 1.94384);
}

-(double)milesPerHourToMetersPerSecond:(double)speed
{
    return (double)(speed * 0.44704);
}

-(double)kilometersPerHourToMetersPerSecond:(double)speed
{
    return (double)(speed * 0.277778);
}

-(double)knotsToMetersPerSecond:(double)speed
{
    return (double)(speed * 0.514444);
}

- (double)metersToMiles:(double)meters
{
    return (double)meters * 0.000621371192;
}

- (double)metersToKilometers:(double)meters
{
    return (double)meters * 0.001;
}

- (double)metersToNauticalMiles:(double)meters
{
    return (double)meters * 0.000539957;
}

- (double)milesToMeters:(double)miles
{
    return (double)miles * 1609.34;
}

- (double)kilometersToMeters:(double)kilos
{
    return (double)kilos * 1000;
}

- (double)nauticalMilesToMeters:(double)nm
{
    return (double)nm * 1852;
}


#pragma mark CLLocationManager delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationDistance distanceBetween = [newLocation distanceFromLocation:oldLocation];
    
    if ([newLocation distanceFromLocation:_currentLocation] >= _odometerAccuracy ) {
        
        _currentLocation = newLocation;
        
        if (_odometerTripA < 9999999) {
            _odometerTripA += distanceBetween;
        } else {
            _odometerTripA = 0;
        }
        if (_odometerTripB < 9999999) {
            _odometerTripB += distanceBetween;
        } else {
            _odometerTripB = 0;
        }
        
        if ( _USERDEFHomeLocation != nil) {
            CLLocationDistance directDistance = [newLocation distanceFromLocation:_USERDEFHomeLocation];
            [self setDirectDistanceButtonLabel:directDistance];
        }
        
        [_weatherService updateLocation:_currentLocation andUpdateImmediately:NO];
    }
    
    _currentMetersPerSecond = [newLocation speed];
    _currentAltitude = [newLocation altitude];
    
    [self setOdometerButtonLabel:_odometerTripA metersB:_odometerTripB];
    [self setSpeedButtonLabel:_currentMetersPerSecond];
    [self setAltitudeButtonLabel:_currentAltitude];
    [self setClockButtonLabel];
    [self getCurrentLocationName];
    [self setSunLabel];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    CLLocationDirection trueNorth = [newHeading trueHeading];
    int heading = (int)(round(trueNorth));
    [self setHeadingButtonLabel:heading];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusDenied) {
        //location denied, handle accordingly
        exit(0);
    }  else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        //always called when launched.
        [_locationManager startUpdatingLocation];
        
        if ([CLLocationManager headingAvailable]) {
            _locationManager.headingFilter = _headingAccuracy;
            [_locationManager startUpdatingHeading];
        }
        
        if (_locationManager.location) {
            _currentLocation = _locationManager.location;
            if (_USERDEFHomeLocation == nil) {
                _USERDEFHomeLocation = [_locationManager.location copy];
                [self setDirectDistanceButtonLabel:0.0];
            } else {
                CLLocationDistance directDistance = [_locationManager.location distanceFromLocation:_USERDEFHomeLocation];
                [self setDirectDistanceButtonLabel:directDistance];
            }
        }
        
        [self centerMapView:_currentLocation.coordinate.latitude longitudeSpan:_currentLocation.coordinate.longitude];
        [self getCurrentLocationName];
        [self initWeatherService];
        [self setSunLabel];
    }
}

- (void)getCurrentLocationName
{
    if (_locationManager != nil) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation: _locationManager.location
                       completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error){return;} CLPlacemark *placemark = [placemarks objectAtIndex:0]; [self setLocationButtonLabel:placemark.locality];
         }];
    }
}


#pragma mark WeatherService delegate methods

- (void)weatherService:(WeatherService *)service willBeginDownloadingForLocation:(CLLocation *)location
{
    [_WeatherSpinner startAnimating];
}

- (void)weatherService:(WeatherService *)service didUpdateForLocation:(CLLocation *)location
               celsius:(double)celsius fahrenheit:(double)fahrenheit placename:(NSString *)placename
{
    [_WeatherSpinner stopAnimating];
    _currentTemperature = _weatherService.celsius;
    [self setTempButtonLabel:_currentTemperature];
    [_weatherService updateLocation:_currentLocation andUpdateImmediately:NO];
}

- (void)weatherService:(WeatherService *)service stationLocationDidChange:(CLLocation *)newLocation
           oldLocation:(CLLocation *)oldLocation  stationName:(NSString *)stationName
{
    // Place pin for weather station location if user wants
    if (_USERDEFdropPinForWeatherStations) {
        /*
         MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
         [annotation setCoordinate:CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude)];
         [annotation setTitle:[NSString stringWithFormat:@"Weather Station %@", stationName]]; //You can set the subtitle too
         [self.MapView addAnnotation:annotation];
         */
    }
}
- (void)weatherService:(WeatherService *)service failedToUpdateWithError:(NSError *)error
{
    [_WeatherSpinner stopAnimating];
    //NSLog(@"ws failedToUpdateWithError: %@", [error localizedDescription]);
}
- (void)weatherService:(WeatherService *)service didBecomeInvalidWithError:(NSError *)error
{
    [_WeatherSpinner stopAnimating];
    //NSLog(@"ws didBecomeInvalidWithError: %@", [error localizedDescription]);
}


@end
