//
//  ViewController.m
//  responder
//
//  Created by ilikeido on 15/7/22.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

#define UUIDSTR_ISSC_PROPRIETARY_SERVICE @"FFF0"

#define HAL_KEY_SW_A 0x01
#define HAL_KEY_SW_B 0x02
#define HAL_KEY_SW_C 0x04
#define HAL_KEY_SW_D 0x08
#define HAL_KEY_SW_E 0x10
#define HAL_KEY_START 0xaa


@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) CBCentralManager *manager;

@property(nonatomic,strong) NSMutableArray *peripheralList;

@property(nonatomic,strong)CBPeripheral  *testPeripheral;

@property(nonatomic,strong) NSTimer *connectTimer;

@property(nonatomic,strong) CBCharacteristic *broadcastCharacteristic;

@property(nonatomic,strong) CBCharacteristic *readCharacteristic;

@property(nonatomic,strong) CBCharacteristic *writeCharacteristic;

@property(nonatomic,strong) CBCharacteristic *notifyCharacteristic;

@property(nonatomic,strong) CBCharacteristic *readCharacteristic2;

@property(nonatomic,strong) NSMutableData *recvData;
@property(nonatomic,assign) int packLength;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    _peripheralList = [[ NSMutableArray alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [_manager scanForPeripheralsWithServices:nil options:nil];
    }else if (central.state == CBCentralManagerStatePoweredOff) {
       UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请打开蓝牙" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else if (central.state == CBCentralManagerStateUnknown) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"当前设备不支持蓝牙" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请在设置中允许蓝牙使用" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"dicoveredPeripherals:%@", peripheral);
    [self.peripheralList addObject:peripheral];
    [self.tableView reloadData];
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
}

-(void)proessData{
    if (self.recvData.length>2) {
        NSData *keyData = [self.recvData subdataWithRange:NSMakeRange(0, 1)];
        int temp;
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
        NSData *busData = [data subdataWithRange:NSMakeRange(2, data.length -2)];
        NSString *dataString = [self dataToString:busData];
        NSLog(@"data:%@",dataString);
    }
    NSLog(@"dataCheckError:%@",[self dataToString:data]);
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peripheralList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    CBPeripheral *peripheral = [_peripheralList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",peripheral];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"正在连接");
    _testPeripheral = [_peripheralList objectAtIndex:indexPath.row];
    [self connect:_testPeripheral];
}


@end
