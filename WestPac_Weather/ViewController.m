//
//  ViewController.m
//  WestPac_Weather
//
//  Created by Richard Wu on 19/11/2015.
//  Copyright © 2015 WP. All rights reserved.
//

#import "ViewController.h"

#define kWeatherBaseURL @"https://api.forecast.io/forecast/"
#define kAPIKey @"459f0c9ab67d433c12239a7ab4cb76ae"

//Sydney 
#define kMokLongitute 151.125412
#define kMokLatitude  -33.8275681

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *weatherTextView;

- (IBAction)refreshTapped:(id)sender;

@end

@implementation ViewController {
    CLLocationManager *locationManager;
    float longitude,latitude;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshTapped:nil];
}

- (IBAction)refreshTapped:(id)sender {
    
    if (longitude == 0 || latitude == 0) {
        //No location found, for example, so use mock data
        latitude = kMokLatitude;
        longitude = kMokLongitute;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/%f,%f",kWeatherBaseURL,kAPIKey,latitude, longitude];
    
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (! connectionError && data) {
            //Parse the JSON data
            NSError *err = nil;
            NSDictionary *weatherDict = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &err];
            NSDictionary *weatherSummaryDict = (NSDictionary *)[weatherDict objectForKey:@"currently"];

            dispatch_async(dispatch_get_main_queue(),^(void){
                self.weatherTextView.text = [NSString stringWithFormat:@"%@, Temperature: %0.2f, Feel Like: %0.2f, Humidity: %0.2f", [weatherSummaryDict objectForKey:@"summary"],[[weatherSummaryDict objectForKey:@"temperature"] floatValue],[[weatherSummaryDict objectForKey:@"apparentTemperature"] floatValue],[[weatherSummaryDict objectForKey:@"humidity"] floatValue]];
            });
            
        }
        
    }];
    

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        longitude =  currentLocation.coordinate.longitude;
        latitude = currentLocation.coordinate.latitude;
    }
}
@end
