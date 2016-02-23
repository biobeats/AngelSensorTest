//
//  ViewController.h
//  AngelSensorTest
//
//  Created by Michael Sanelli on 16/02/16.
//  Copyright © 2016 Michael Sanelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController<CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource>
    @property (nonatomic, strong) CBCentralManager *centralManager;
@end

