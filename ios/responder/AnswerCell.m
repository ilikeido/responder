//
//  AnswerCell.m
//  responder
//
//  Created by ilikeido on 15/7/27.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "AnswerCell.h"
#import "DataTool.h"
#import "DeviceHelper.h"

@implementation AnswerCell

- (void)awakeFromNib {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onSubmit:) name:BLE_SUBDEVICE_SUBMIT object:nil];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)onSubmit:(NSNotification *)notification{
    NSString *mac = [notification.object objectForKey:@"mac"];
    NSArray *value = [notification.object objectForKey:@"value"];
    if ([[[DataTool sharedDataTool]nickNameByDeviceName:mac]   isEqual:_lb_name.text]) {
        if ([value containsObject:@"A"]) {
            [_iv_a setImage:[UIImage imageNamed:@"iconA_s"]];
        }else{
            [_iv_a setImage:[UIImage imageNamed:@"iconA_n"]];
        }
        if ([value containsObject:@"B"]) {
            [_iv_b setImage:[UIImage imageNamed:@"iconB_s"]];
        }else{
            [_iv_b setImage:[UIImage imageNamed:@"iconB_n"]];
        }
        if ([value containsObject:@"C"]) {
            [_iv_c setImage:[UIImage imageNamed:@"iconC_s"]];
        }else{
            [_iv_c setImage:[UIImage imageNamed:@"iconC_n"]];
        }
        if ([value containsObject:@"D"]) {
            [_iv_d setImage:[UIImage imageNamed:@"iconD_s"]];
        }else{
            [_iv_d setImage:[UIImage imageNamed:@"iconD_n"]];
        }
        if ([value containsObject:@"E"]) {
            [_iv_e setImage:[UIImage imageNamed:@"iconE_s"]];
        }else{
            [_iv_e setImage:[UIImage imageNamed:@"iconE_n"]];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
