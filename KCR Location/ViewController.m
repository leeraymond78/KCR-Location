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
#define key_name @"name"
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
                      @"StationsData" ofType:@"plist"];
    NSArray* eastRail = [[[NSDictionary alloc] initWithContentsOfFile:path]autorelease][@"EastRail"];
    [self initLocationArray:eastRail];
    
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services is not enabled");
    }
    NSNumber* selected = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedStation"];
    if(selected){
        [self stationSelectedWithIndex:[selected integerValue]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationSelected:) name:@"StationSelected" object:nil];
}

-(void)initLocationArray:(NSArray*)array{
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:array];
    for (int x = 0; x < [newArray count]; x++) {
        NSDictionary* miniDict = newArray[x];
        CLLocation* location = [self locationFromString:[miniDict objectForKey:key_coordinate]];
        NSMutableDictionary * newMiniDict = [NSMutableDictionary dictionaryWithDictionary:miniDict];
        [newMiniDict setObject:location forKey:key_location];
        [newArray replaceObjectAtIndex:x withObject:newMiniDict];
    }
    eastRailArray= [[NSArray alloc] initWithArray:newArray];
}

-(CLLocation*)locationFromString:(NSString*)locationStr{
    NSArray* array = [locationStr componentsSeparatedByString:@","];
    double latitude = [[array objectAtIndex:0] doubleValue];
    double longtitude = [[array objectAtIndex:1] doubleValue];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
    
    return location;
}
CLLocation* currentLoc;
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLoc = [locations lastObject];
        //    NSLog(@"location updated:%@",currentLoc);
    CLLocationDistance minDistance;
    NSInteger index;
    [self getMinDistance:&minDistance index:&index];
    
    NSDictionary* dict = eastRailArray[index];
    CLLocation *location = [dict objectForKey:key_location];
    currentStation = dict;
    [nearestStationLabel setText:[dict objectForKey:key_name]];
    [self.view setBackgroundColor:[self colorFromString:dict[@"RGB"]]];
    if(selectedStation){
        CGFloat timeLeftMin = [[selectedStation objectForKey:key_time]integerValue] - [currentStation[key_time]integerValue];
        NSInteger newIndex =((timeLeftMin>=0)?index+1:index-1);
        if(newIndex>=eastRailArray.count){
            newIndex = eastRailArray.count-1;
        }else if(newIndex<0){
            newIndex = 1;
        }
        CLLocationDistance wholeDistance = [eastRailArray[newIndex][key_location] distanceFromLocation:location];
        CGFloat percentange = wholeDistance/minDistance;
        
        timeLeftMin = timeLeftMin*percentange;
        [timeNeededLabel setText:[NSString stringWithFormat:@"%@ Minutes",@(fabsf(timeLeftMin))]];
        NSLog(@"currently closest station is %@\ndistance is %@\nmins is %@ min",dict[key_name],@(minDistance),@(fabsf(timeLeftMin)));
    }
    
}

-(void)getMinDistance:(CLLocationDistance*)minDistance index:(NSInteger*)index{
    *minDistance = CLLocationDistanceMax;
    
    for( int x = 0; x<eastRailArray.count;x++)
    {
        NSDictionary* dict = eastRailArray[x];
        CLLocationDistance distance = [currentLoc distanceFromLocation:dict[key_location]];
        if(distance!=0){
            if(distance < *minDistance){
            *minDistance = distance;
            *index =x;
            }
        }
    }
}

-(UIColor*)colorFromString:(NSString*)string{
    NSArray* array = [string componentsSeparatedByString:@"	"];
    return [UIColor colorWithRed:[array[0]floatValue]/255.0f green:[array[1]floatValue]/255.0f blue:[array[2]floatValue]/255.0f alpha:1];
}
-(IBAction)gotoSetting:(id)sender{
    [settingVC setEastRailArray:eastRailArray];
    [[settingVC view] setFrame:self.view.frame];
    
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromLeft;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:.6f];
    [UIView setAnimationTransition:trans forView:[self.view window] cache: YES];
    [self presentViewController:settingVC animated:NO completion:nil];
    [UIView commitAnimations];
}

-(void)stationSelected:(NSNotification*)notification{
    NSNumber * index = [notification object];
    [self stationSelectedWithIndex:[index integerValue]];
}

-(void)stationSelectedWithIndex:(NSInteger)index{
    [toStationLabel setText:[NSString stringWithFormat:@"to %@",eastRailArray[index ][key_name]]];
    selectedStation = eastRailArray[index];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

@end
