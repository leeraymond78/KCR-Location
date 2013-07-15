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
    NSDictionary* _eastRailDict;
    
    IBOutlet UIButton * backbtn;
    IBOutlet UITableView* _tableView;
}

@property (nonatomic, retain) NSDictionary* eastRailDict;;

@end
