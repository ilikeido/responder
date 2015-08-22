//
//  DataTool.h
//  responder
//
//  Created by ilikeido on 15/7/26.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARCSingletonTemplate.h"

@interface NickDevice : NSObject

@property(nonatomic,strong) NSString *deviceName;

@property(nonatomic,strong) NSString *nickName;

@end

@interface DataTool : NSObject

SYNTHESIZE_SINGLETON_FOR_HEADER(DataTool)

@property(nonatomic,strong) NSMutableArray *dataList;

-(NSString *)nickNameByDeviceName:(NSString *)deviceName;

-(void)saveNickName:(NSString *)nickname byDeviceName:(NSString *)deviceName;

-(NSMutableDictionary *)choosePersonsMap;

-(NSDictionary *)personChooseMap;

-(void)clearChoose;

@end
