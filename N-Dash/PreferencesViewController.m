//
//  PreferencesViewController.m
//  N-Dash
//
//  Created by John Schilling on 3/20/16.
//  Copyright © 2016 StimpSoft LLC. All rights reserved.
//

#import "PreferencesViewController.h"

@interface PreferencesViewController ()

@property (weak, nonatomic) IBOutlet UISwitch               *AlertOnSpeedSwitch;
@property (weak, nonatomic) IBOutlet UITextField            *SpeedLimitTextField;
@property (weak, nonatomic) IBOutlet UILabel                *SpeedLimitLabelField;
@property (weak, nonatomic) IBOutlet UISegmentedControl     *DistanceUnitsSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl     *TempUnitsSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl     *WeatherRefreshSelector;
@property (weak, nonatomic) IBOutlet UILabel                *AppVersionBuildLabel;

@property (nonatomic) int                                   USERDEFweatherUpdatePeriod;         // 0 : never, 1: 1 min, 2: 5 min, 3 10 min.

@property (nonatomic) double                                USERDEFspeedLimit;       // in meters per second
@property (nonatomic) bool                                  USERDEFplaySoundOnSpeedWarning;

@property (nonatomic) int                                   USERDEFDistanceUnits;            //0 mph, 1 kmh, 2 knots
@property (nonatomic) int                                   USERDEFTemperatureUnits;            //0 fahrenheit, 1 celsius

@property (nonatomic, copy) NSArray                         *UNITS_SPEED;
@property (nonatomic, copy) NSArray                         *UNITS_DISTANCE;
@property (nonatomic, copy) NSArray                         *UNITS_TEMP;


- (void)setInterface;
- (void)loadPreferences;
- (void)savePreferences;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"View did load: PreferencesViewController");
    
    NSString *appNameString         = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *appVersionString      = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuildNumberString  = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIFont *tinyLabelFont = [UIFont systemFontOfSize:10];
    
    NSAttributedString *appLabelText = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ v%@ build %@",appNameString, appVersionString, appBuildNumberString]
                                                                        attributes: @{NSParagraphStyleAttributeName:paragraphStyle,
                                                                                    NSFontAttributeName: tinyLabelFont,
                                                                                    NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    _AppVersionBuildLabel.attributedText = appLabelText;
    
    
    _SpeedLimitTextField.delegate = self;
    [_SpeedLimitTextField setReturnKeyType:UIReturnKeyDone];
    
    _UNITS_SPEED                        = @[@"MPH", @"KPH", @"Knots"];
    _UNITS_DISTANCE                     = @[@"mi", @"k", @"nm"];
    _UNITS_TEMP                         = @[@"F", @"C"];
    
    [self loadPreferences];
    
    [self setInterface];
}

- (void)setInterface
{
    int speed = (int) round([self convertMetersPerSecondToSpeed:_USERDEFspeedLimit]);
    [_SpeedLimitTextField setText:[NSString stringWithFormat:@"%d",speed]];
    
    [_AlertOnSpeedSwitch setOn:_USERDEFplaySoundOnSpeedWarning];
    _SpeedLimitLabelField.text = _UNITS_SPEED[_USERDEFDistanceUnits];
    
    [_SpeedLimitTextField setEnabled:_USERDEFplaySoundOnSpeedWarning];
    [_SpeedLimitLabelField setEnabled:_USERDEFplaySoundOnSpeedWarning];
    
    [_DistanceUnitsSelector setSelectedSegmentIndex:_USERDEFDistanceUnits];
    [_TempUnitsSelector setSelectedSegmentIndex:_USERDEFTemperatureUnits];
}

- (IBAction)SavePreferences:(id)sender {
    
    _USERDEFplaySoundOnSpeedWarning = [_AlertOnSpeedSwitch isOn];
    _USERDEFspeedLimit = [self convertSpeedToMetersPerSecond:[_SpeedLimitTextField.text doubleValue]];
    _USERDEFDistanceUnits = (int)_DistanceUnitsSelector.selectedSegmentIndex;
    _USERDEFTemperatureUnits = (int)_TempUnitsSelector.selectedSegmentIndex;
    [self savePreferences];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UIViewController *viewController =
    [[UIStoryboard storyboardWithName:@"Main"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    [self presentViewController:viewController animated:NO completion:nil];
}

- (BOOL)textField: (UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString: (NSString *)string {
    
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterNoStyle];
    
    NSString * newString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    NSNumber * number = [nf numberFromString:newString];
    
    if (number) {
        //_USERDEFspeedLimit = [self convertSpeedToMetersPerSecond:[_SpeedLimitTextField.text doubleValue]];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)AlarmSwitchDidChange:(id)sender {
    
    [_SpeedLimitTextField setEnabled:[_AlertOnSpeedSwitch isOn]];
    [_SpeedLimitLabelField setEnabled:[_AlertOnSpeedSwitch isOn]];
    
    [self setInterface];
}

- (IBAction)DistanceUnitsClickerClicked:(id)sender {
    [self setInterface];
}

- (IBAction)TemperatureUnitsClickerClicked:(id)sender {
    [self setInterface];
}


- (IBAction)TemperatureRefreshClickerClicked:(id)sender {
    
}


- (void)loadPreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults integerForKey:@"USERDEFDistanceUnits"]) {
        _USERDEFDistanceUnits = (int)[defaults integerForKey:@"USERDEFDistanceUnits"];
    } else {
        //NSLog(@"USERDEFDistanceUnits not found.");
    }
    
    if ([defaults integerForKey:@"USERDEFTemperatureUnits"]) {
        _USERDEFTemperatureUnits = (int)[defaults integerForKey:@"USERDEFTemperatureUnits"];
    } else {
        //NSLog(@"USERDEFTemperatureUnits not found.");
    }

    if ([defaults integerForKey:@"USERDEFweatherUpdatePeriod"]) {
        _USERDEFweatherUpdatePeriod = (int)[defaults integerForKey:@"USERDEFweatherUpdatePeriod"];
    } else {
        //NSLog(@"USERDEFweatherUpdatePeriod not found.");
        _USERDEFweatherUpdatePeriod = 6;
    }
    
    if ([defaults boolForKey:@"USERDEFplaySoundOnSpeedWarning"]) {
        _USERDEFplaySoundOnSpeedWarning = (bool)[defaults boolForKey:@"USERDEFplaySoundOnSpeedWarning"];
    } else {
        //NSLog(@"USERDEFplaySoundOnSpeedWarning not found.");
        _USERDEFplaySoundOnSpeedWarning = false;
    }
    
    if ([defaults doubleForKey:@"USERDEFspeedLimit"]) {
        _USERDEFspeedLimit = (double)[defaults doubleForKey:@"USERDEFspeedLimit"];
    } else {
        //NSLog(@"USERDEFspeedLimit not found.");
        _USERDEFspeedLimit = [self convertSpeedToMetersPerSecond:90.000];
    }
}

- (void)savePreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setInteger:_USERDEFDistanceUnits forKey:@"USERDEFDistanceUnits"];
    [defaults setInteger:_USERDEFTemperatureUnits forKey:@"USERDEFTemperatureUnits"];
    [defaults setInteger:_USERDEFweatherUpdatePeriod forKey:@"USERDEFweatherUpdatePeriod"];
    [defaults setBool:_USERDEFplaySoundOnSpeedWarning forKey:@"USERDEFplaySoundOnSpeedWarning"];
    [defaults setDouble:_USERDEFspeedLimit forKey:@"USERDEFspeedLimit"];
    
    [defaults synchronize];
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


@end
