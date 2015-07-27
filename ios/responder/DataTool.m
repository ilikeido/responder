//
//  DataTool.m
//  responder
//
//  Created by ilikeido on 15/7/26.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "DataTool.h"

@interface DataTool ()

@property(nonatomic,strong) NSMutableDictionary *deviceDict;

@end

@implementation DataTool

SYNTHESIZE_SINGLETON_FOR_CLASS(DataTool)

-(id)init{
    self = [super init];
    if (self) {
        self.deviceDict = [NSMutableDictionary dictionary];
        self.dataList = [NSMutableArray array];
    }
    return self;
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


@end
