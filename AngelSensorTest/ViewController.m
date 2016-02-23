//
//  ViewController.m
//  AngelSensorTest
//
//  Created by Michael Sanelli on 16/02/16.
//  Copyright © 2016 Michael Sanelli. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

NSString* const WAVEFORM_SIGNAL_SERVICE = @"481d178c-10dd-11e4-b514-b2227cce2b54";
NSString* const WAVEFORM_SIGNAL_FEATURE = @"4cb32ae6-0cfe-47dc-a4f6-59f52cdc2910";


@implementation ViewController {
    NSMutableArray *array;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self configureTableView];
    
}

- (void)configureTableView
{
    array = [NSMutableArray array];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = nil;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.autoresizingMask = UIViewAutoresizingNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral* currentPer = [array objectAtIndex:indexPath.row];
    [self.centralManager connectPeripheral:currentPer options:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    CBPeripheral* currentPer = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = (currentPer.name ? currentPer.name : @"Not available");
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [array count];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    CBPeripheral* currentPer = peripheral;
    
    NSLog(@"Peripheral %@", currentPer);
    
    if ([currentPer.identifier  isEqual: @"8789DAEE-FBDB-D025-DDA7-409EC6E1897C"]) {
        [self.centralManager connectPeripheral:currentPer options:nil];
    }
    
    if (![array containsObject:currentPer]) {
        [array addObject:currentPer];
    }
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"Connection successfull to peripheral: %@",peripheral);
    
    peripheral.delegate = self;
    if(peripheral.services)
        [self peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
    else
        [peripheral discoverServices:nil]; //yet to discover, normal path. Discover your services needed
    //Do somenthing after successfull connection.
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for(CBService* svc in peripheral.services)
    {
        if(svc.characteristics)
            [self peripheral:peripheral didDiscoverCharacteristicsForService:svc error:nil]; //already discovered characteristic before, DO NOT do it again
        else
            [peripheral discoverCharacteristics:nil
                                     forService:svc]; //need to discover characteristics
    }
}


-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Service %@", service);
    for(CBCharacteristic* c in service.characteristics)
    {
        //Do some work with the characteristic...
        //NSLog(@"Characteristic found %@", c);

        if ([service.UUID isEqual:[CBUUID UUIDWithString:WAVEFORM_SIGNAL_SERVICE]]) {
            //NSLog(@"Characteristic found %@", c);

            if( [c.UUID isEqual:[CBUUID UUIDWithString:WAVEFORM_SIGNAL_FEATURE]] )
            {
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *) characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error changing notification state: %@",
              [error localizedDescription]);
    }
    NSData *data = characteristic.value;
    
    NSLog(@"New value %@", data);
    
    if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:WAVEFORM_SIGNAL_FEATURE]] ) {
        
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Connection failed to peripheral: %@",peripheral);
    
    //Do something when a connection to a peripheral failes.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
