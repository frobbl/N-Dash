//
//  WeatherService.m
//
//
//  Created by John Schilling on 3/14/16.
//  Copyright © 2016 Frobble Software LLC. All rights reserved.
//

#import "WeatherService.h"

@interface WeatherService ()

- (void)beginAutoUpdating;
- (void)cancelAutoUpdating;
- (void)createAndRunUpdateTimer;
- (void)weatherTimerFunction:(NSTimer *)timer;
- (NSError *)createErrorForURLSessionDownloadFailure:(NSString *)errorDescription;
- (NSError *)createErrorForDownloadFailureInformationMissing;

@end

@implementation WeatherService


int     SSrequestTimeout        = 15;  // for URL download sessions
int     SSresourceTimeout       = 30; // for URL download sessions
int     SSmaxConnections        = 3;   // for URL download sessions
double  NIL_NUMBER              = -9999.00;

@synthesize delegate;

@synthesize urllocation         = _urllocation;
@synthesize stlocation          = _stlocation;
@synthesize fahrenheit          = _fahrenheit;
@synthesize celsius             = _celsius;
@synthesize autoupdates         = _autoupdates;
@synthesize placename           = _placename;
@synthesize weatherurl          = _weatherurl;
@synthesize METAR               = _METAR;
@synthesize updateinterval      = _updateinterval;


#pragma PUBLIC FUNCTIONS
- (id)init {
    self = [super init];
    if (self) {
        self.fahrenheit         = NIL_NUMBER;
        self.celsius            = NIL_NUMBER;
        self.autoupdates        = YES;
        self.placename          = nil;
        self.urllocation        = nil;
        self.updateinterval     = 0;
    }
    return self;
}

- (id)initWithDelegate:(id<WeatherServiceDelegate>)initdelegate location:(CLLocation *)initlocation
        updateInterval:(double)initinterval autoUpdates:(BOOL)initauto beginDownloading:(BOOL)begin
{
    //NSLog(@"initing (initinterval %f)", initinterval);
    self = [super init];
    self.delegate       = initdelegate;
    self.urllocation    = [initlocation copy];
    self.stlocation     = [initlocation copy];
    self.updateinterval = initinterval;
    self.autoupdates    = initauto;
    if (begin) {
        [self updateWeather];
    }
    return self;
}

- (void)updateWeather
{
    //NSLog(@"updateWeather (self.updateinterval: %f, self.autoupdates: %i)",self.updateinterval,self.autoupdates);
    if (self.urllocation == nil) {
        //NSLog(@"self.urllocation == nil");
        NSError *error = [self createErrorForDownloadFailureInformationMissing];
        [delegate weatherService:self didBecomeInvalidWithError:error];
        return;
    }
    
    if (self.updateinterval == 0) {
        self.fahrenheit         = NIL_NUMBER;
        self.celsius            = NIL_NUMBER;
        return;
    }
    
    NSString *weatherGovURL = @"http://forecast.weather.gov/MapClick.php";
    _weatherurl = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@?lat=%f&lon=%f&FcstType=json",
                                                           weatherGovURL,
                                                           self.urllocation.coordinate.latitude,
                                                           self.urllocation.coordinate.longitude]];
    //NSLog(@"%@",_weatherurl);
    NSURL *weatherURL = [NSURL URLWithString:_weatherurl];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/xml"}];
    sessionConfig.timeoutIntervalForRequest = SSrequestTimeout;
    sessionConfig.timeoutIntervalForResource = SSresourceTimeout;
    sessionConfig.HTTPMaximumConnectionsPerHost = SSmaxConnections;
    
    NSURLSession *weatherSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                 delegate:self
                                                            delegateQueue:nil];
    if (weatherSession) {
        NSURLSessionDownloadTask *downloadTask = [weatherSession downloadTaskWithURL:weatherURL];
        [downloadTask resume];
    }
}

- (void)updateLocation:(CLLocation *)location andUpdateImmediately:(BOOL)update
{
    self.urllocation = [location copy];
    if (update) {
        [self updateWeather];
    }
}

- (void)startAutoUpdating
{
    [self beginAutoUpdating];
}

- (void)stopAutoUpdating
{
    [self cancelAutoUpdating];
}

- (void)setAutoUpdateInterval:(int)interval
{
    self.updateinterval = interval;
}




#pragma PRIVATE FUNCTIONS

- (void)beginAutoUpdating
{
    //NSLog(@"beginAutoUpdating (self.updateinterval: %f, self.autoupdates: %i)",self.updateinterval,self.autoupdates);
    if (!self.autoupdates) {
        self.autoupdates = true;
    }
    [self createAndRunUpdateTimer];
}

- (void)cancelAutoUpdating
{
    //NSLog(@"cancelAutoUpdating (self.updateinterval: %f, self.autoupdates: %i)",self.updateinterval,self.autoupdates);;
    if (self.autoupdates) {
        self.autoupdates = false;
    }
}

- (void)createAndRunUpdateTimer
{
    //NSLog(@"createAndRunUpdateTimer (self.updateinterval: %f, self.autoupdates: %i)",self.updateinterval,self.autoupdates);
    NSTimer *updateTimer = [NSTimer timerWithTimeInterval:self.updateinterval
                                                   target:self
                                                 selector:@selector(weatherTimerFunction:)
                                                 userInfo:nil
                                                  repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
}

- (void)weatherTimerFunction:(NSTimer *)timer
{
    // //NSLog(@"weatherTimerFunction (self.updateinterval: %f, self.autoupdates: %i)",self.updateinterval,self.autoupdates);
    // this is only called by the auto updating timer. so if the timer has been invalidated since being created, dont update.
    if (self.autoupdates) {
        [self updateWeather];
    }
}


- (NSError *)createErrorForURLSessionDownloadFailure:(NSString *)errorDescription
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Retreval of weather from weather.gov failed: %@", errorDescription),};
    NSError *error = [NSError errorWithDomain:@"stimpsoft.ndash.nsurldownloaderror"
                                         code:-57
                                     userInfo:userInfo];
    return error;
}

- (NSError *)createErrorForDownloadFailureInformationMissing
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Weather Service update failed, location not set.", nil),};
    NSError *error = [NSError errorWithDomain:@"stimpsoft.ndash.weatherlocationdownloaderror"
                                         code:-69
                                     userInfo:userInfo];
    return error;
}















#pragma mark NSURLSessionDelegate Methods

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    NSData *jsonData = [NSData dataWithContentsOfURL:location];
    NSError *jsonParsingError = nil;
    if (jsonData) {
        NSDictionary *alldata = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonParsingError];
        if (alldata) {
            NSDictionary *observation = [alldata objectForKey:@"currentobservation"];
            if (observation) {
                NSString *tempstring = [observation valueForKey:@"Temp"];
                if (tempstring) {
                    self.fahrenheit = [tempstring intValue];
                    self.celsius = (self.fahrenheit - 32) / 1.8;
                } else {
                    self.fahrenheit = NIL_NUMBER;
                    self.celsius = NIL_NUMBER;
                }
            }
            NSDictionary *locdata = [alldata objectForKey:@"location"];
            if (locdata) {
                NSString *placename = [locdata valueForKey:@"areaDescription"];
                if (placename) {
                    self.placename = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",placename]];
                    NSString *latstr = [locdata valueForKey:@"latitude"];
                    NSString *lonstr = [locdata valueForKey:@"longitude"];
                    NSString *elvstr = [locdata valueForKey:@"elevation"];
                    NSString *metstr = [locdata valueForKey:@"metar"];
                    double newlat = [latstr doubleValue];
                    double newlon = [lonstr doubleValue];
                    _elevation = [elvstr intValue];
                    _METAR = [[NSMutableString alloc] initWithString:[metstr copy]];
                    CLLocation *newloc = [[CLLocation alloc] initWithLatitude:newlat longitude:newlon];
                    CLLocationDistance distanceThreshold = 1.0; // in meters
                    if ([newloc distanceFromLocation:_stlocation] >= distanceThreshold) {
                        CLLocation *oldloc = [_stlocation copy];
                        _stlocation = [newloc copy];
                        if (self.delegate) {
                            dispatch_async(dispatch_get_main_queue(),^(void){
                                [delegate weatherService:self stationLocationDidChange:newloc oldLocation:oldloc stationName:_METAR];
                            });
                        }
                    } else {
                    }
                }
            }
        }
    }
    
    if (self.autoupdates) {
        [self createAndRunUpdateTimer];
    }
    
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(),^(void){
            [delegate weatherService:self didUpdateForLocation:self.urllocation celsius:self.celsius fahrenheit:self.fahrenheit placename:[NSString stringWithFormat:@"%@", self.placename]];
        });
    }
    
    [session finishTasksAndInvalidate];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    if (error) {
        //NSLog(@"URLSession failed: %@",[error localizedDescription]);
        NSError *myError = [self createErrorForURLSessionDownloadFailure:[error localizedDescription]];
        [delegate weatherService:self failedToUpdateWithError:myError];
        [session finishTasksAndInvalidate];
    }
}






@end
