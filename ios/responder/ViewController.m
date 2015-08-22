//
//  ViewController.m
//  responder
//
//  Created by ilikeido on 15/7/22.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "ViewController.h"
#import "DeviceHelper.h"
#import "UIScrollView+EmptyDataSet.h"
#import "GiFHUD.h"
#import "SubDeviceCell.h"
#import "DataTool.h"
#import "NickNameVC.h"
#import "AnswerVC.h"
#import "ReportVC.h"

@interface ViewController ()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,strong) NSMutableArray *devices;

@property(nonatomic,strong) NSMutableArray *subDevices;

@property(nonatomic,assign) int mode;

@property (weak, nonatomic) IBOutlet UIButton *btn_start;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.subDevices = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceFound) name:BLE_DEVICE_FOUND object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onOnline:) name:BLE_SUBDEVICE_ONLINE object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onOffline:) name:BLE_SUBDEVICE_OFFLINE object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ReportVC *vc = [[ReportVC alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onOnline:(NSNotification *)notification{
    NSString *mac = [notification.object objectForKey:@"mac"];
    if (![self.subDevices containsObject:mac]) {
        [self.subDevices addObject:mac];
    }
    [self.tableView reloadData];
}

-(void)onOffline:(NSNotification *)notification{
    NSString *mac = [notification.object objectForKey:@"mac"];
    if ([self.subDevices containsObject:mac]) {
        [self.subDevices removeObject:mac];
    }
    [self.tableView reloadData];
}

-(void)onCheck:(NSNotification *)notification{
    NSString *mac = [notification.object objectForKey:@"mac"];
    NSLog(@"%@点击了重置",mac);
}

-(void)deviceFound{
    [GiFHUD dismiss];
    self.devices = [[DeviceHelper sharedDeviceHelper].deviceNames mutableCopy];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.mode == 0) {
        return self.devices.count;
    }else{
        return self.subDevices.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    if (_mode == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        }
        if (self.mode == 0) {
            NSString *deviceName = [self.devices objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",deviceName];
        }else if(self.mode == 1){
            NSString *deviceName = [self.subDevices objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",deviceName];
        }
    }else if(_mode == 1){
         SubDeviceCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"SubDeviceCell"];
        [tableView registerNib:[UINib nibWithNibName:@"SubDeviceCell" bundle:nil] forCellReuseIdentifier:@"SubDeviceCell"];
        cell1 = [tableView dequeueReusableCellWithIdentifier:@"SubDeviceCell"];
        cell1.lb_name.text = [[DataTool sharedDataTool] nickNameByDeviceName:[_subDevices objectAtIndex:indexPath.row]];
        cell =  cell1;
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.mode == 0) {
        NSString *deviceName = [self.devices objectAtIndex:indexPath.row];
        [[DeviceHelper sharedDeviceHelper]connectDeviceByName:deviceName];
        [[DeviceHelper sharedDeviceHelper]stopScan];
        self.mode = 1;
        [_btn_start setHidden:NO];
        [self.tableView reloadData];
    }else{
        NickNameVC *vc = [[NickNameVC alloc]init];
        vc.deviceName = [_subDevices objectAtIndex:indexPath.row];
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
}


#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSMutableAttributedString *attriString ;
    
    if (_mode == 0) {
        attriString = [[NSMutableAttributedString alloc]initWithString:@"找开蓝牙，点击添加设备"];
    }else{
        attriString = [[NSMutableAttributedString alloc]initWithString:@"正在寻找子设备.."];
        
    }
    [attriString addAttribute:(NSString *)NSForegroundColorAttributeName
                        value:(id)[UIColor grayColor].CGColor range:NSMakeRange(0, attriString.length)];
    
    return attriString;

}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    
    NSMutableAttributedString *attriString ;
    
    if (_mode == 0) {
        return nil;
    }else{
        attriString = [[NSMutableAttributedString alloc]initWithString:@"点击取消"];
        
    }
    [attriString addAttribute:(NSString *)NSForegroundColorAttributeName
                        value:(id)[UIColor redColor].CGColor range:NSMakeRange(0, attriString.length)];
    
    return attriString;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView;{
    if (_mode == 0) {
        return [UIImage imageNamed:@"btn_add"];
    }else{
        return nil;
    }
    
}


#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView{
    return YES;
}


- (void)emptyDataSetDidTapView:(UIScrollView *)scrollView;{
    if (_mode == 0) {
        [GiFHUD setGifWithImageName:@"could.gif"];
        [GiFHUD show];
        [[DeviceHelper sharedDeviceHelper]scan];
    }
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView{
    if (_mode == 1) {
        [self.devices removeAllObjects];
        [[DeviceHelper sharedDeviceHelper] reset];
        _mode = 0;
        [_btn_start setHidden:YES];
        [self.tableView reloadData];
    }
}

- (IBAction)begin:(id)sender {
    
    [DataTool sharedDataTool].dataList = self.subDevices;
    AnswerVC *vc = [[AnswerVC alloc]init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
