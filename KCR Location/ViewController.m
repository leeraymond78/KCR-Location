//
//  ViewController.m
//  KCR Location
//
//  Created by Raymond Lee on 12/7/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "ViewController.h"
#import "SettingViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#define key_order @"order"
#define key_coordinate @"coordinate"
#define key_location @"location"
#define key_time @"time"

SettingViewController* settingVC;

- (void)viewDidLoad
{
    [super viewDidLoad];
    settingVC = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    locationManager = [[CLLocationManager alloc]init];
    [locationManager setDelegate:self];
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"EastRail" ofType:@"plist"];
    eastRailDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    [self initLocationDict:eastRailDict];
    
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager startUpdatingLocation];
        
    } else {
        NSLog(@"Location services is not enabled");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationSelected:) name:@"StationSelected" object:nil];
    
}

-(void)initLocationDict:(NSDictionary*)dict{
    NSMutableDictionary* newDict = [[NSMutableDictionary alloc]initWithCapacity:0];
    for (NSString* miniDictKey in dict) {
        NSDictionary* miniDict = [dict objectForKey:miniDictKey];
        CLLocation* location = [self locationFromString:[miniDict objectForKey:key_coordinate]];
        NSMutableDictionary * newMiniDict = [NSMutableDictionary dictionaryWithDictionary:miniDict];
        [newMiniDict setObject:location forKey:key_location];
        [newDict setObject:newMiniDict forKey:miniDictKey];
    }
    eastRailDict = [[NSDictionary alloc]initWithDictionary:newDict];
}

-(CLLocation*)locationFromString:(NSString*)locationStr{
    NSArray* array = [locationStr componentsSeparatedByString:@","];
    double latitude = [[array objectAtIndex:0] doubleValue];
    double longtitude = [[array objectAtIndex:1] doubleValue];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
    
    return location;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation* currentLoc = [locations lastObject];
    NSLog(@"location updated:%@",currentLoc);
    CLLocationDistance minDistance = CLLocationDistanceMax;
    for (NSString* key in eastRailDict){
        NSDictionary* dict = [eastRailDict objectForKey:key];
        CLLocation *location = [dict objectForKey:key_location];
        CLLocationDistance distance = [currentLoc distanceFromLocation:location];
        if(distance<minDistance){
            minDistance = distance;
            currentStation = dict;
            [nearestStationLabel setText:key];
            if(selectedStation){
                [self updateCurrentStation];
            }
            NSLog(@"currently closest station is %@\ndistance is %f",key,minDistance);
        }
    }
}
-(IBAction)gotoSetting:(id)sender{
    [settingVC setEastRailDict:eastRailDict];
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromLeft;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:.6f];
    [UIView setAnimationTransition:trans forView:[self.view window] cache: YES];
    [self presentViewController:settingVC animated:NO completion:nil];
    [UIView commitAnimations];
}

-(void)stationSelected:(NSNotification*)notification{
    NSNumber * index = [notification object];
    for(NSString* key in [eastRailDict allKeys]){
        NSDictionary* object = [eastRailDict objectForKey:key];
        if([index integerValue] == [[object objectForKey:@"order"] integerValue]){
            selectedStation = object;
            NSInteger time = [[object objectForKey:@"time"]integerValue] - [[currentStation objectForKey:@"time"]integerValue];
            time = abs(time);
            [timeNeededLabel setText:[NSString stringWithFormat:@"%d Minutes",time]];
            [toStationLabel setText:[NSString stringWithFormat:@"to %@",key]];
        }
    }
}

-(void)updateCurrentStation{
    NSInteger time = [[selectedStation objectForKey:@"time"]integerValue] - [[currentStation objectForKey:@"time"]integerValue];
    time = abs(time);
    [timeNeededLabel setText:[NSString stringWithFormat:@"%d Minutes",time]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
