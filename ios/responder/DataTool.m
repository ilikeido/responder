//
//  DataTool.m
//  responder
//
//  Created by ilikeido on 15/7/26.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "DataTool.h"
#import "DeviceHelper.h"
#import "LKDBHelper.h"

@implementation NickDevice

+(NSString *)getTableName
{
    return @"NickDeviceTable";
}

@end

@interface DataTool ()

@property(nonatomic,strong) NSMutableDictionary *chooseDict;

@end

@implementation DataTool

SYNTHESIZE_SINGLETON_FOR_CLASS(DataTool)

-(id)init{
    self = [super init];
    if (self) {
        self.dataList = [NSMutableArray array];
        self.chooseDict = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onSubmit:) name:BLE_SUBDEVICE_SUBMIT object:nil];
        [NickDevice getUsingLKDBHelper];
        self.chooseDict = [@{@"小明":@[@"A",@"B",@"C",@"D"],@"小红":@[@"A",@"B",@"C"],@"小白":@[@"B",@"C",@"D"],@"小钟":@[@"C",@"D"]} mutableCopy];
    }
    return self;
}

-(void)onSubmit:(NSNotification *)notification{
    NSString *mac = [notification.object objectForKey:@"mac"];
    NSArray *value = [notification.object objectForKey:@"value"];
    NSString *nickname = [[DataTool sharedDataTool]nickNameByDeviceName:mac] ;
    [_chooseDict setValue:value forKey:nickname];
}


-(NSDictionary *)personChooseMap{
    return _chooseDict;
}

-(NSMutableDictionary *)choosePersonsMap{
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

-(void)clearChoose{
    [_chooseDict removeAllObjects];
}

-(NSString *)nickNameByDeviceName:(NSString *)deviceName{
    NickDevice *entity = [NickDevice searchSingleWithWhere:[NSString stringWithFormat:@"deviceName='%@'",deviceName] orderBy:nil];
    if (entity) {
        return entity.nickName;
    }
    return deviceName;
}

-(void)saveNickName:(NSString *)nickname byDeviceName:(NSString *)deviceName{
    NickDevice *entity = [NickDevice searchSingleWithWhere:[NSString stringWithFormat:@"deviceName='%@'",deviceName] orderBy:nil];
    if(!entity){
        entity = [[NickDevice alloc]init];
        entity.deviceName = deviceName;
        entity.nickName = nickname;
        [entity saveToDB];
    }else{
        entity.nickName = nickname;
        [entity updateToDB];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
