//
//  ReportVC.m
//  responder
//
//  Created by ilikeido on 15/8/10.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import "ReportVC.h"
#import "responder-Swift.h"
#import "DataTool.h"

@interface ReportVC ()<ChartViewDelegate>

@property (nonatomic, weak) IBOutlet PieChartView *chartView;

@property (weak, nonatomic) IBOutlet UITextView *tv_content;

@property (weak, nonatomic) IBOutlet UIView *chooseView;

@property (weak, nonatomic) IBOutlet UIImageView *navBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;

@property(nonatomic, strong) NSMutableArray *selectedAnsnwers;

@property(nonatomic, assign) int menu_show;

@property(nonatomic, strong) NSMutableArray *truePersons;

@end

@implementation ReportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    _selectedAnsnwers = [[NSMutableArray alloc]init];
    _truePersons = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initUI{
    _topLayoutConstraint.constant = -_chooseView.frame.size.height - 4;
    self.menu_show = 0;
    _chartView.delegate = self;
    _chartView.usePercentValuesEnabled = YES;
    _chartView.holeTransparent = YES;
    _chartView.centerTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    _chartView.holeRadiusPercent = 0.58;
    _chartView.transparentCircleRadiusPercent = 0.61;
    _chartView.descriptionText = @"";
    _chartView.drawCenterTextEnabled = YES;
    _chartView.drawHoleEnabled = YES;
    _chartView.rotationAngle = 0.0;
    _chartView.rotationEnabled = YES;
    _chartView.centerText = @"选择结果统计";
    
    ChartLegend *l = _chartView.legend;
    l.position = ChartLegendPositionRightOfChart;
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 0.0;
    l.yOffset = 0.0;
    
    [_chartView animateWithXAxisDuration:1.5 yAxisDuration:1.5 easingOption:ChartEasingOptionEaseOutBack];
    [self setData];
}

- (IBAction)backAction:(id)sender {
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}

-(BOOL)isRightChooses:(NSArray *)answers{
    if (answers.count == self.selectedAnsnwers.count) {
        for (NSString *answer in answers) {
            if (![self.selectedAnsnwers containsObject:answer]) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (void)setData
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSDictionary *dict = [[DataTool sharedDataTool] choosePersonsMap];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    if (self.menu_show == 0 || _selectedAnsnwers.count == 0) {
        for (int i=0;i<dict.count;i++) {
            NSString *name = [dict.allKeys objectAtIndex:i];
            NSArray *array = [dict objectForKey:name];
            if (array.count > 0) {
                [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:array.count xIndex:i]];
                [xVals addObject:[NSString stringWithFormat:@"%@(%d人)",name,(int)array.count]];
            }
        }
    }else{
        [_truePersons removeAllObjects];
        int trueCount = 0;
        for (NSString *personName in [DataTool sharedDataTool].personChooseMap.keyEnumerator) {
            NSArray *answer = [[DataTool sharedDataTool].personChooseMap objectForKey:personName];
            if ([self isRightChooses:answer]) {
                trueCount ++;
                [_truePersons addObject:personName];
            }
        }
        [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:trueCount xIndex:0]];
        [xVals addObject:[NSString stringWithFormat:@"回答正确(%d人)",(int)trueCount]];
        
        [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:[DataTool sharedDataTool].personChooseMap.count - trueCount xIndex:1]];
        [xVals addObject:[NSString stringWithFormat:@"回答错误(%d人)",(int)[DataTool sharedDataTool].personChooseMap.count - trueCount]];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithYVals:yVals1 label:@""];
    dataSet.sliceSpace = 1.0;
    
    // add a lot of colors
    
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
    [colors addObjectsFromArray:ChartColorTemplates.liberty];
    [colors addObjectsFromArray:ChartColorTemplates.pastel];
    [colors addObject:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
    
    dataSet.colors = colors;
    
    PieChartData *data = [[PieChartData alloc] initWithXVals:xVals dataSet:dataSet];
    

    [data setValueTextColor:UIColor.grayColor];
    
    _chartView.data = data;
    [_chartView highlightValues:nil];
    [_chartView animateWithXAxisDuration:1.5 yAxisDuration:1.5 easingOption:ChartEasingOptionEaseOutBack];
}

- (IBAction)filterAction:(id)sender {
    self.menu_show = 1;
    [UIView animateWithDuration:0.5 animations:^{
       _topLayoutConstraint.constant = - 4;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)hideAction:(id)sender {
    self.menu_show = 0;
    [UIView animateWithDuration:0.5 animations:^{
        _topLayoutConstraint.constant = -_chooseView.frame.size.height - 4;
        [self.view layoutIfNeeded];
    }];
    [self reflashUI];
}

- (IBAction)selectAction:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    NSString *anser = @"";
    switch (btn.tag) {
        case 1:
            anser = @"A";
            break;
        case 2:
            anser = @"B";
            break;
        case 3:
            anser = @"C";
            break;
        case 4:
            anser = @"D";
            break;
        case 5:
            anser = @"E";
            break;
        default:
            break;
    }
    if ([self.selectedAnsnwers containsObject:anser]) {
        [self.selectedAnsnwers removeObject:anser];
    }else{
        [self.selectedAnsnwers addObject:anser];
    }
    [self reflashUI];
}


-(void)reflashUI{
    _tv_content.text = nil;
    [self setData];
}


#pragma mark - ChartViewDelegate
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSDictionary *dict = [[DataTool sharedDataTool] choosePersonsMap];
    if (self.menu_show == 0 || _selectedAnsnwers.count == 0) {
        NSString *name = [dict.allKeys objectAtIndex:entry.xIndex];
        NSArray *array = [dict objectForKey:name];
        NSString *names = [array componentsJoinedByString:@"\t"];
        _tv_content.text = [NSString stringWithFormat:@"选择答案%@的小朋友：\n\n%@",name,names];
    }else{
        if (entry.xIndex == 0) {
            NSString *names = [_truePersons componentsJoinedByString:@"\t"];
            _tv_content.text = [NSString stringWithFormat:@"选择正确答案的小朋友：\n%@",names];
        }else{
            NSMutableArray *array = [[DataTool sharedDataTool].personChooseMap.allKeys mutableCopy];
            [array removeObjectsInArray:_truePersons];
            NSString *names = [array componentsJoinedByString:@"\t"];
            _tv_content.text = [NSString stringWithFormat:@"还需努力的小朋友：\n%@",names];
        }
    }
    
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    _tv_content.text = @"";
}

@end
