//
//  NickNameVC.m
//  responder
//
//  Created by ilikeido on 15/7/27.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "NickNameVC.h"
#import "DataTool.h"

@interface NickNameVC ()

@end

@implementation NickNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_deviceName) {
        self.tf_nickname.text = [[DataTool sharedDataTool]nickNameByDeviceName:_deviceName];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[DataTool sharedDataTool]clearChoose];
}

- (IBAction)back:(id)sender {
    if (_tf_nickname.text.length>0) {
        [[DataTool sharedDataTool]saveNickName:_tf_nickname.text byDeviceName:_deviceName];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
