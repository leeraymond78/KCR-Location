//
//  ViewController.h
//  KCR Location
//
//  Created by Raymond Lee on 12/7/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate>{
    NSArray* eastRailArray;
    CLLocationManager *locationManager;
    NSDictionary* currentStation;
    NSDictionary* selectedStation;
    
    IBOutlet UILabel* nearestStationLabel;
    IBOutlet UILabel* timeNeededLabel;
    IBOutlet UILabel* toStationLabel;
}

@end
