//
//  SubDeviceCell.m
//  responder
//
//  Created by ilikeido on 15/7/26.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "SubDeviceCell.h"
#import "DeviceHelper.h"
#import "DataTool.h"

@implementation SubDeviceCell

- (void)awakeFromNib {
    // Initialization code
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stateChange:) name:BLE_SUBDEVICE_CHECK object:nil];
}

-(void)stateChange:(NSNotification *)notification{
    NSString *mac = [notification.object objectForKey:@"mac"];
    if ([[[DataTool sharedDataTool]nickNameByDeviceName:mac]   isEqual:_lb_name.text]) {
        [self.iv_state setImage:[UIImage imageNamed:@"state_s"]];
    }else{
        [self.iv_state setImage:[UIImage imageNamed:@"state_n"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
