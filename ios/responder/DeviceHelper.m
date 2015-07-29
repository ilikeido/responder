//
//  DeviceHelper.m
//  responder
//
//  Created by ilikeido on 15/7/25.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "DeviceHelper.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define UUIDSTR_ISSC_PROPRIETARY_SERVICE @"FFF0"

#define HAL_KEY_SW_A 0x01
#define HAL_KEY_SW_B 0x02
#define HAL_KEY_SW_C 0x04
#define HAL_KEY_SW_D 0x08
#define HAL_KEY_SW_E 0x10
#define HAL_KEY_START 0xaa

@interface DeviceHelper ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property(nonatomic,strong) NSMutableDictionary *deviceDict;

@property(nonatomic,strong) CBCentralManager *manager;

@property(nonatomic,strong) NSMutableArray *peripheralList;

@property(nonatomic,strong) CBPeripheral  *testPeripheral;

@property(nonatomic,strong) NSTimer *connectTimer;

@property(nonatomic,strong) CBCharacteristic *broadcastCharacteristic;

@property(nonatomic,strong) CBCharacteristic *readCharacteristic;

@property(nonatomic,strong) CBCharacteristic *writeCharacteristic;

@property(nonatomic,strong) CBCharacteristic *notifyCharacteristic;

@property(nonatomic,strong) CBCharacteristic *readCharacteristic2;

@property(nonatomic,strong) NSMutableData *recvData;
@property(nonatomic,assign) int packLength;

@property(nonatomic,strong) NSTimer *ackTimer;


@end

@implementation DeviceHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(DeviceHelper)


-(id)init{
    self = [super init];
    if (self) {
        self.deviceDict = [NSMutableDictionary dictionary];
        self.deviceNames = [NSMutableArray array];
        self.peripheralList = [NSMutableArray array];
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];

    }
    return self;
}

-(void)scan{
    [_manager scanForPeripheralsWithServices:nil options:nil];
}

-(void)stopScan{
    [_manager stopScan];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [_manager scanForPeripheralsWithServices:nil options:nil];
    }else if (central.state == CBCentralManagerStatePoweredOff) {
        
    }else if (central.state == CBCentralManagerStateUnknown) {
        
    }else {
        
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"dicoveredPeripherals:%@", peripheral);
    if(![self.peripheralList containsObject:peripheral]){
        [self.peripheralList addObject:peripheral];
        NSString *perpheralName = [self peripheralName:peripheral];
        [self.deviceNames addObject:perpheralName];
        [self.deviceDict setObject:peripheral forKey:perpheralName];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:BLE_DEVICE_FOUND object:nil];
}

-(NSString *)peripheralName:(CBPeripheral *)peripheral{
    return [NSString stringWithFormat:@"%@(%@)",peripheral.name,peripheral.identifier.UUIDString];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [_connectTimer invalidate];//停止时钟
    NSLog(@"Did connect to peripheral: %@", peripheral);
    _testPeripheral = peripheral;
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    NSLog(@"didDiscoverServices");
    
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        
        //        if ([self respondsToSelector:@selector(DidNotifyFailConnectService:withPeripheral:error:)])
        //            [self.delegate DidNotifyFailConnectService:nil withPeripheral:nil error:nil];
        
        return;
    }
    
    
    for (CBService *service in peripheral.services)
    {
        NSLog(@"Service found with UUID: %@", service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]])
        {
            NSLog(@"Service found with UUID: %@", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        
        return;
    }
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        NSLog(@"Discovered write characteristics:%@ ,perperties:%lu for service: %@", characteristic.UUID, (unsigned long)characteristic.properties,service.UUID);
        switch (characteristic.properties) {
            case CBCharacteristicPropertyBroadcast:
                _broadcastCharacteristic = characteristic;
                break;
            case CBCharacteristicPropertyRead:{
                if (_readCharacteristic) {
                    _readCharacteristic2 = characteristic;
                }else{
                    _readCharacteristic = characteristic;
                }
            }
                break;
            case CBCharacteristicPropertyWrite:
                _writeCharacteristic = characteristic;
                break;
            case CBCharacteristicPropertyNotify:
                _notifyCharacteristic = characteristic;
                break;
            default:
                break;
        }
    }
    if (_notifyCharacteristic) {
        [_testPeripheral setNotifyValue:YES forCharacteristic:_notifyCharacteristic];
    }
    if (_writeCharacteristic) {
        _ackTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(writeAck) userInfo:nil repeats:YES];
        [_ackTimer fire];
    }
}

-(void)writeAck{
    int i = 1;
    NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
    [_testPeripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse ];
}

-(void)proessData{
    if (self.recvData.length>2) {
        NSData *keyData = [self.recvData subdataWithRange:NSMakeRange(0, 1)];
        int temp = 0;
        [keyData getBytes: &temp length: sizeof(temp)];
        if (temp == HAL_KEY_START) {
            NSData *lengthData = [self.recvData subdataWithRange:NSMakeRange(1, 1)];
            [lengthData getBytes: &temp length: sizeof(temp)];
            self.packLength = temp;
        }
        if (self.packLength>0 && self.recvData.length >= self.packLength) {
            NSData *data = [self.recvData subdataWithRange:NSMakeRange(0, self.packLength + 3)];
            [self submitData:data];
            NSData *subData = [self.recvData subdataWithRange:NSMakeRange(data.length, self.recvData.length - data.length)];
            if (subData.length == 0) {
                self.recvData = [NSMutableData data];
            }else{
                self.recvData = [subData mutableCopy];
            }
            [self proessData];
        }
    }
    
}

-(void)submitData:(NSData *)data{
    BOOL flag = [self checkData:data];
    if (flag) {
        NSData *busData = [data subdataWithRange:NSMakeRange(2, data.length - 3)];
        [self handleData:busData];
    }else{
        NSLog(@"dataCheckError:%@",[self dataToString:data]);
    }
    
}

-(void)handleData:(NSData *)data {
    NSString *dataString = [self dataToString:data];
    NSString *type = [dataString substringToIndex:4];
    NSString *mac = [dataString substringWithRange:NSMakeRange(4, 16)];
    NSLog(@"mac :%@，type:%@",mac,type);
    NSMutableArray *answers = [NSMutableArray array];
    NSString *noticicationName = @"";
    if ([@"f901" isEqual:type ]) {
        noticicationName = BLE_SUBDEVICE_ONLINE;
    }
    if ([@"f904" isEqual:type ]) {
        noticicationName = BLE_SUBDEVICE_OFFLINE;
    }
    if ([@"f903" isEqual:type ]) {
        noticicationName = BLE_SUBDEVICE_CHECK;
    }
    
    if ([@"f902" isEqual:type ]) {
        noticicationName = BLE_SUBDEVICE_SUBMIT;
        const unsigned char *txbuf =  [data bytes];
        const unsigned int choose = txbuf[10];
        if (choose & HAL_KEY_SW_A) {
            [answers addObject:@"A"];
        }
        if (choose & HAL_KEY_SW_B) {
            [answers addObject:@"B"];
        }
        if (choose & HAL_KEY_SW_C) {
            [answers addObject:@"C"];
        }
        if (choose & HAL_KEY_SW_D) {
            [answers addObject:@"D"];
        }
        if (choose & HAL_KEY_SW_E) {
            [answers addObject:@"E"];
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:noticicationName object:@{@"mac":mac,@"value":answers}];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    NSData *data = characteristic.value;
    if (!self.recvData) {
        self.recvData = [[NSMutableData alloc]init];
    }
    [self.recvData appendData:data];
    [self proessData];
    return;
    
    NSString *hexStr = [self dataToString:data];
    NSLog(@"data:%@",hexStr);
    if ([[hexStr substringToIndex:2] isEqual:@"aa"]) {
        self.recvData = nil;
        self.recvData = [[NSMutableData alloc]init];
        [self.recvData appendData:data];
    }else{
        NSString *hexStr = [self dataToString:data];
        NSRange rang = [hexStr rangeOfString:@"aa"];
        if (rang.length == 0) {
            [self.recvData appendData:data];
        }else{
            [self.recvData appendData:[data subdataWithRange:NSMakeRange(0, rang.location/2)]];
        }
        NSString *allData = [self dataToString:self.recvData];
        NSString *dataString = [allData substringWithRange:NSMakeRange(4, allData.length - 2 - 4)];
        NSLog(@"result:%@",dataString);
        [self processData:dataString];
        if (rang.length != 0){
            self.recvData = nil;
            self.recvData = [[NSMutableData alloc]init];
            NSData *subData = [data subdataWithRange:NSMakeRange(rang.location/2, data.length - rang.location/2)];
            [self.recvData appendData:subData];
        }
    }
    
}


#pragma mark - function

-(BOOL)checkData:(NSData *)data{
    BOOL flag = false;
    const unsigned char *txbuf =  [data bytes];
    unsigned int tx_xor = 0;
    if (txbuf[0] == 0xaa) {
        unsigned int size = txbuf[1];
        unsigned char i;
        tx_xor ^= size;
        for (i =0 ; i<size; ++i) {
            tx_xor ^= txbuf[2+i];
        }
        Byte checkByte = tx_xor & 0xff;
        if (txbuf[2+i] == checkByte) {
            flag = true;
        }
    }
    return flag;
}

-(void)processData:(NSString *)dataString{
    
}

-(NSString *)dataToString:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
//连接指定的设备
-(BOOL)connect:(CBPeripheral *)peripheral
{
    NSLog(@"connect start");
    _testPeripheral = nil;
    
    [_manager connectPeripheral:peripheral
                        options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    
    //开一个定时器监控连接超时的情况
    _connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectTimeout:) userInfo:peripheral repeats:NO];
    
    return (YES);
}

-(void)connectTimeout:(CBPeripheral *)peripheral{
    NSLog(@"超时!");
}

#pragma mark - function
-(void)connectDeviceByName:(NSString *)deviceName{
    CBPeripheral *peripheral = [self.deviceDict objectForKey:deviceName];
    [_manager connectPeripheral:peripheral options:nil];
}

-(void)disconnectDeviceByName:(NSString *)deviceName{
    CBPeripheral *peripheral = [self.deviceDict objectForKey:deviceName];
    [_manager cancelPeripheralConnection:peripheral];
}

-(void)reset{
    if (_ackTimer) {
        [_ackTimer invalidate];
        _ackTimer = nil;
    }
    if (_testPeripheral) {
        [_manager cancelPeripheralConnection:_testPeripheral];
        _testPeripheral = nil;
    }
    [_manager stopScan];
}

@end
