//
//  AnswerVC.m
//  responder
//
//  Created by ilikeido on 15/7/27.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "AnswerVC.h"
#import "AnswerCell.h"
#import "DataTool.h"

@interface AnswerVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AnswerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [DataTool sharedDataTool].dataList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerCell"];
    [tableView registerNib:[UINib nibWithNibName:@"AnswerCell" bundle:nil] forCellReuseIdentifier:@"AnswerCell"];
    cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerCell"];
    cell.lb_name.text = [[DataTool sharedDataTool] nickNameByDeviceName:[[DataTool sharedDataTool].dataList objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
