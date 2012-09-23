//
//  AppDelegate.m
//  ble
//
//  Created by Peter Morton on 23/09/12.
//  Copyright (c) 2012 Peter Morton. All rights reserved.
//

#import "AppDelegate.h"
#import <IOBluetooth/IOBluetooth.h>

@interface AppDelegate () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, retain) CBCentralManager *manager;
@property (nonatomic, retain) CBPeripheral *peripheral;

@property (nonatomic, retain) NSDictionary *known_uuids;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.known_uuids = @{
        [CBUUID UUIDWithString:@"03879136-EAA2-47A1-BA01-936BA9B86F3C"] : @"Peter",
        [CBUUID UUIDWithString:@"E70A9276-AEC3-47A5-BA43-C1A8C803DF35"] : @"Pi"};
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch(central.state)
    {
        case CBCentralManagerStatePoweredOff:
            self.message.stringValue = @"Bluetooth is powered off";
            break;
            
        case CBCentralManagerStatePoweredOn:
            self.message.stringValue = @"Scanning for devices";
            [self.manager scanForPeripheralsWithServices:nil options:nil];
            break;
            
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateUnauthorized:
            self.message.stringValue = @"Problem initialising";
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    CBUUID *uuid = [CBUUID UUIDWithCFUUID:peripheral.UUID];
    NSString *name = self.known_uuids[uuid];
    if(name) {
        self.message.stringValue = [NSString stringWithFormat:@"Detected %@", name];
        [self.manager stopScan];
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        [self.manager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
    }
    else {
        self.message.stringValue = @"Unknown device discovered";
    }
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral readRSSI];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.message.stringValue = @"Scanning for devices";
    self.value.stringValue = @"####";
    [self.manager scanForPeripheralsWithServices:nil options:nil];

}

# pragma mark - Peripheral delegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if(peripheral.RSSI.intValue == 127 || peripheral.RSSI.intValue < -40)
    {
        // Wait for proximity
        [peripheral readRSSI];
    }
    else {
        CBUUID *uuid = [CBUUID UUIDWithCFUUID:peripheral.UUID];
        self.message.stringValue = [NSString stringWithFormat:@"Welcome, %@", self.known_uuids[uuid]];
        
        // Discover specific battery service
        [peripheral discoverServices:@[[CBUUID UUIDWithString:@"e001"]]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService* service in peripheral.services) {
        // Discover battery characteristic
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"e101"]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{   
    for (CBCharacteristic *characteristic in service.characteristics) {
        // Read immediately
        [peripheral readValueForCharacteristic:characteristic];
        // Notify on change
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.value.stringValue = [characteristic.value description];
}




@end
