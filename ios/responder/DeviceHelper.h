//
//  DeviceHelper.h
//  responder
//
//  Created by ilikeido on 15/7/25.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARCSingletonTemplate.h"

#define BLE_DEVICE_FOUND @"BLE_DEVICE_FOUND"

#define BLE_SUBDEVICE_ONLINE @"BLE_SUBDEVICE_ONLINE"
#define BLE_SUBDEVICE_OFFLINE @"BLE_SUBDEVICE_OFFLINE"
#define BLE_SUBDEVICE_SUBMIT @"BLE_SUBDEVICE_SUBMIT"
#define BLE_SUBDEVICE_CHECK @"BLE_SUBDEVICE_CHECK"

@interface DeviceHelper : NSObject

@property(nonatomic,strong) NSMutableArray *deviceNames;

-(void)scan;

-(void)stopScan;

-(void)reset;

-(void)connectDeviceByName:(NSString *)deviceName;

-(void)disconnectDeviceByName:(NSString *)deviceName;


SYNTHESIZE_SINGLETON_FOR_HEADER(DeviceHelper)

@end
