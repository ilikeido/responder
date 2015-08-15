//
//  DataTool.h
//  responder
//
//  Created by ilikeido on 15/7/26.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARCSingletonTemplate.h"

@interface DataTool : NSObject

SYNTHESIZE_SINGLETON_FOR_HEADER(DataTool)

@property(nonatomic,strong) NSMutableArray *dataList;

-(NSString *)nickNameByDeviceName:(NSString *)deviceName;

-(void)saveNickName:(NSString *)nickname byDeviceName:(NSString *)deviceName;

-(NSMutableDictionary *)choosePersonsMap;

@end
