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

@end

@implementation ReportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initUI{
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setData
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSDictionary *dict = [[DataTool sharedDataTool] choosePersonsMap];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    for (int i=0;i<dict.count;i++) {
        NSString *name = [dict.allKeys objectAtIndex:i];
        NSArray *array = [dict objectForKey:name];
        if (array.count > 0) {
            [yVals1 addObject:[[BarChartDataEntry alloc] initWithValue:array.count xIndex:i]];
            [xVals addObject:[NSString stringWithFormat:@"%@(%d人)",name,array.count]];
        }
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
    
//    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
//    pFormatter.numberStyle = NSNumberFormatterNoStyle;
//    pFormatter.maximumFractionDigits = 1;
//    pFormatter.multiplier = @1.f;
//    pFormatter.percentSymbol = @" %";
//    [data setValueFormatter:pFormatter];
//    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:UIColor.grayColor];
    
    _chartView.data = data;
    [_chartView highlightValues:nil];
}

//- (void)optionTapped:(NSString *)key
//{
//    if ([key isEqualToString:@"toggleValues"])
//    {
//        for (ChartDataSet *set in _chartView.data.dataSets)
//        {
//            set.drawValuesEnabled = !set.isDrawValuesEnabled;
//        }
//        
//        [_chartView setNeedsDisplay];
//    }
//    
//    if ([key isEqualToString:@"toggleXValues"])
//    {
//        _chartView.drawSliceTextEnabled = !_chartView.isDrawSliceTextEnabled;
//        
//        [_chartView setNeedsDisplay];
//    }
//    
//    if ([key isEqualToString:@"togglePercent"])
//    {
//        _chartView.usePercentValuesEnabled = !_chartView.isUsePercentValuesEnabled;
//        
//        [_chartView setNeedsDisplay];
//    }
//    
//    if ([key isEqualToString:@"toggleHole"])
//    {
//        _chartView.drawHoleEnabled = !_chartView.isDrawHoleEnabled;
//        
//        [_chartView setNeedsDisplay];
//    }
//    
//    if ([key isEqualToString:@"drawCenter"])
//    {
//        _chartView.drawCenterTextEnabled = !_chartView.isDrawCenterTextEnabled;
//        
//        [_chartView setNeedsDisplay];
//    }
//    
//    if ([key isEqualToString:@"animateX"])
//    {
//        [_chartView animateWithXAxisDuration:3.0];
//    }
//    
//    if ([key isEqualToString:@"animateY"])
//    {
//        [_chartView animateWithYAxisDuration:3.0];
//    }
//    
//    if ([key isEqualToString:@"animateXY"])
//    {
//        [_chartView animateWithXAxisDuration:3.0 yAxisDuration:3.0];
//    }
//    
//    if ([key isEqualToString:@"spin"])
//    {
//        [_chartView spinWithDuration:2.0 fromAngle:_chartView.rotationAngle toAngle:_chartView.rotationAngle + 360.f];
//    }
//    
//    if ([key isEqualToString:@"saveToGallery"])
//    {
//        [_chartView saveToCameraRoll];
//    }
//}

#pragma mark - ChartViewDelegate
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSDictionary *dict = [[DataTool sharedDataTool] choosePersonsMap];
    NSString *name = [dict.allKeys objectAtIndex:entry.xIndex];
    NSArray *array = [dict objectForKey:name];
    _tv_content.text = [array componentsJoinedByString:@"\n"];
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    _tv_content.text = @"";
}

@end
