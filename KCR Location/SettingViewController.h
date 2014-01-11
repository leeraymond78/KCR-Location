//
//  SettingViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"


@interface SettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSArray* _eastRailArray;
    
    IBOutlet UIButton * backbtn;
    IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) NSArray* eastRailArray;

@end
