//
//  DataTool.m
//  responder
//
//  Created by ilikeido on 15/7/26.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "DataTool.h"
#import "DeviceHelper.h"

@interface DataTool ()

@property(nonatomic,strong) NSMutableDictionary *deviceDict;

@property(nonatomic,strong) NSMutableDictionary *chooseDict;

@end

@implementation DataTool

SYNTHESIZE_SINGLETON_FOR_CLASS(DataTool)

-(id)init{
    self = [super init];
    if (self) {
        self.deviceDict = [NSMutableDictionary dictionary];
        self.dataList = [NSMutableArray array];
        self.chooseDict = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onSubmit:) name:BLE_SUBDEVICE_SUBMIT object:nil];
    }
    return self;
}

-(void)onSubmit:(NSNotification *)notification{
    NSString *mac = [notification.object objectForKey:@"mac"];
    NSArray *value = [notification.object objectForKey:@"value"];
    NSString *nickname = [[DataTool sharedDataTool]nickNameByDeviceName:mac] ;
    [_chooseDict setValue:value forKey:nickname];
}

-(NSMutableDictionary *)choosePersonsMap{
    
    _chooseDict = [@{@"小明":@[@"A",@"B"],@"小红":@[@"A",@"C"],@"小李":@[@"C",@"D"],@"小汤":@[@"A"]} mutableCopy];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *array_a = [NSMutableArray array];
    NSMutableArray *array_b = [NSMutableArray array];
    NSMutableArray *array_c = [NSMutableArray array];
    NSMutableArray *array_d = [NSMutableArray array];
    NSMutableArray *array_e = [NSMutableArray array];
    for (NSString *name in _chooseDict.keyEnumerator) {
        NSArray *value = [_chooseDict objectForKey:name];
        if ([value containsObject:@"A"]) {
            [array_a addObject:name];
        }
        if ([value containsObject:@"B"]) {
            [array_b addObject:name];
        }
        if ([value containsObject:@"C"]) {
            [array_c addObject:name];
        }
        if ([value containsObject:@"D"]) {
            [array_d addObject:name];
        }
        if ([value containsObject:@"E"]) {
            [array_e addObject:name];
        }
    }
    if (array_a.count > 0) {
        [dict setObject:array_a forKey:@"A"];
    }
    if (array_b.count > 0) {
        [dict setObject:array_b forKey:@"B"];
    }
    if (array_c.count > 0) {
        [dict setObject:array_c forKey:@"C"];
    }
    if (array_d.count > 0) {
        [dict setObject:array_d forKey:@"D"];
    }
    if (array_e.count > 0) {
        [dict setObject:array_e forKey:@"E"];
    }
    return dict;
}

-(NSString *)nickNameByDeviceName:(NSString *)deviceName{
    NSString *name = [_deviceDict objectForKey:deviceName];
    if (!name) {
        return deviceName;
    }
    return name;
}

-(void)saveNickName:(NSString *)nickname byDeviceName:(NSString *)deviceName{
    [_deviceDict setObject:nickname forKey:deviceName];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
