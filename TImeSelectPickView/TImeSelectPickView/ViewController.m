//
//  ViewController.m
//  TImeSelectPickView
//
//  Created by 这是C先生 on 2020/3/26.
//  Copyright © 2020 这是C先生. All rights reserved.
//

#import "ViewController.h"
#import "HSXSelectTimeView.h"
#define Screen_Bounds [UIScreen mainScreen].bounds
@interface ViewController ()
/// <#type#>
@property (nonatomic,strong) UILabel * timeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 20)];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor redColor];
    [self.view addSubview:_timeLabel];
    
    UIButton *selectTime = [[UIButton alloc]initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 50)];
    [selectTime setTitle:@"选择时间" forState:UIControlStateNormal];
    [selectTime setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [selectTime addTarget:self action:@selector(selectTimeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:selectTime];
}

- (void)selectTimeBtnClick:(UIButton *)btn{
    
    HSXSelectTimeView *sele = [[HSXSelectTimeView alloc]initWithFrame:Screen_Bounds withType:SelectStartTime withDate:nil];
    
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:sele];
    
    
    
    
    
    sele.callBack = ^(NSString * _Nonnull timeString) {
        self.timeLabel.text = timeString;
    };
}

@end
