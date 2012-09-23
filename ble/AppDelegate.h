//
//  AppDelegate.h
//  ble
//
//  Created by Peter Morton on 23/09/12.
//  Copyright (c) 2012 Peter Morton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *message;
@property (weak) IBOutlet NSTextField *value;

@end
