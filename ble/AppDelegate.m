//
//  AppDelegate.m
//  ble
//
//  Created by Peter Morton on 23/09/12.
//  Copyright (c) 2012 Peter Morton. All rights reserved.
//

#import "AppDelegate.h"
#import <IOBluetooth/IOBluetooth.h>

@interface AppDelegate () <CBCentralManagerDelegate>

@property (nonatomic, retain) CBCentralManager *manager;
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
            self.message.stringValue = @"Bluetooth is powered on";
            break;
            
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateUnauthorized:
            self.message.stringValue = @"Problem initialising";
    }
    
}



@end
