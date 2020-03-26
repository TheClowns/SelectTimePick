//
//  HSXSelectTimeView.m
//  SuiXing
//
//  Created by 这是C先生 on 2020/3/23.
//  Copyright © 2020 这是C先生. All rights reserved.
//

#import "HSXSelectTimeView.h"

#define Screen_Height  [UIScreen mainScreen].bounds.size.height
#define Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Screen_Bounds [UIScreen mainScreen].bounds
#define Scale_W(value) ((Screen_Width > Screen_Height?Screen_Height:Screen_Width)/375*(value))

#define RegularFontX(value)  [UIFont systemFontOfSize:Scale_W(value)]

#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
// 判断iPhoneX
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
#define kIsIphoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define Height_StatusBar ((IS_IPHONE_X == YES || kIsIphoneX == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 44.0 : 20.0)
#define Height_NavBar ((IS_IPHONE_X == YES || kIsIphoneX == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 88.0 : 64.0)
#define Height_TabBar ((IS_IPHONE_X == YES || kIsIphoneX == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 83.0 : 49.0)
#define Safe_TabBar ((IS_IPHONE_X == YES || kIsIphoneX == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 34.0 : 0.0)
#define ReductionHeight_StatusBar ((IS_IPHONE_X == YES || kIsIphoneX == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 0 : 24.0)


@interface HSXSelectTimeView()<UIPickerViewDelegate,UIPickerViewDataSource>
/// <#type#>
@property (nonatomic,strong) UIView * selectTimeView;

/// <#type#>
@property (nonatomic,strong) UIButton * cancleTimeBtn;

@property (nonatomic,strong) UIButton * confirmTimeBtn;


/// <#type#>
@property (nonatomic,strong) UILabel * selectTimeLabel;


/// <#type#>
@property (nonatomic,strong) UIDatePicker * datePicker;


/// <#type#>
@property (nonatomic,strong) UIPickerView * pickTimeView;
@property (nonatomic,assign) Type3 type;

@property(nonatomic,strong)NSMutableArray *pickerViewDataArr;//存储常规的日期数据分五个数组
@property(nonatomic,strong)NSMutableArray *nowPickerViewDataArr;//存储当前时间数组
@property(nonatomic,assign)NSInteger selectRow0;//第一例选择的行数
@property(nonatomic,assign)NSInteger selectRow1;//第一例选择的行数
@property(nonatomic,assign)NSInteger selectRow2;//第一例选择的行数
@property(nonatomic,assign)NSInteger selectRow3;//第一例选择的行数

@property(nonatomic,assign)NSInteger selectedB;//记录是选择开始还是结束时间按钮 0 为没有   1为开始时间 2为结束时间

@property(nonatomic,assign)NSInteger defaultYear;//当前时间年
@property(nonatomic,assign)NSInteger defaultMonth;//当前时间月
@property(nonatomic,assign)NSInteger defaultDay;//当前时间日
@property(nonatomic,assign)NSInteger defaultHour;//当前时间时
@property(nonatomic,assign)NSInteger defaultMinute;


//1为开始时间 2为结束时间
@property(nonatomic,strong)NSTimer * timer;//定时器  一分钟加载一次时间选择器的数据，并刷新


/// <#type#>
@property (nonatomic,strong) NSMutableArray * yearArr;

/// <#type#>
@property (nonatomic,strong) NSMutableArray * dateAndWeekArr;

/// <#type#>
@property (nonatomic,strong) NSMutableArray * hourArr;

/// <#type#>
@property (nonatomic,strong) NSMutableArray * minArr;



/// <#type#>
@property (nonatomic,strong) NSMutableArray * nowAllYearDateHourMinArr;

/// <#type#>
@property (nonatomic,strong) NSMutableArray * nowAllYearDateHourMinPlusArr;

@property (nonatomic,strong) NSMutableArray * nowAllYearDateHourMinPlusPlusArr;



/// <#type#>
@property (nonatomic,strong) NSMutableArray * nowHourArr;


/// <#type#>
@property (nonatomic,strong) NSMutableArray * otherHourArr;
/// <#type#>
@property (nonatomic,strong) NSMutableArray * nowMinArr;

/// <#type#>
@property (nonatomic,strong) NSMutableArray * otherMinArr;



/// <#type#>
@property (nonatomic,strong) NSDate * startDate;


@end

static NSDateFormatter *_dateFormatter;





@implementation HSXSelectTimeView


- (instancetype)initWithFrame:(CGRect)frame withType:(Type3)type withDate:(nonnull NSDate *)startDate{
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        self.startDate = startDate;
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
        self.nowAllYearDateHourMinArr = [NSMutableArray array];
        self.nowAllYearDateHourMinPlusArr = [NSMutableArray array];
        self.nowAllYearDateHourMinPlusPlusArr = [NSMutableArray array];
        [self getNewData];
        [self createSubViews];
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (touch) {
      CGPoint point = [touch locationInView:self];
       
        CALayer *layer = [self.layer hitTest:point];
        if (layer == self.layer) {
            [self removeFromSuperview];
        }
    }
}

#pragma mark -- 初始化对象
-(void)initObject{
    self.selectRow0 =0;
    self.selectRow1 =0;
    self.selectRow2 = 0;
    self.selectRow3 = 0;
    self.selectedB = 0;
    //初始化定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

//定时器触发运行事件
-(void)timerAction:(NSTimer*)sender{
    //清空原来的数据
    self.nowPickerViewDataArr = nil;
    self.pickerViewDataArr = nil;
    //获取数据
    [self getData];
    //刷新列表
    [self.pickTimeView reloadAllComponents];
}

- (void)getNewData{
     self.pickerViewDataArr = [NSMutableArray array];
    
    NSDate *date = [NSDate date];
    
    if (self.startDate) {
        date = self.startDate;
    }
    
     NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [format stringFromDate:date];
    
    int currentMin = [[dateString componentsSeparatedByString:@" "].lastObject componentsSeparatedByString:@":"].lastObject.intValue;
    if (currentMin >=30) {
        
        date = [NSDate dateWithTimeInterval:(60-currentMin)*60 sinceDate:date];
    }else{
        dateString = [dateString stringByReplacingCharactersInRange:NSMakeRange(dateString.length - 2, 2) withString:@"30"];
        
        date =[format dateFromString:dateString];
    }
    
    
    
    
    NSCalendar * canlendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents * components = [canlendar components:unitFlags fromDate:date];
    NSInteger nowY = [components year];
    NSInteger nowM = [components month];
    NSInteger nowD = [components day];
    NSInteger nowH = [components hour];
    NSInteger nowF = [components minute];

    NSInteger nowW= [components weekday];
    NSString *str = [NSString stringWithFormat:@"%d年-%d月-%d日-%@-%d时-%d分",nowY,nowM,nowD,[self getWeekWith:nowW],nowH,nowF];
    
    NSLog(@"%@",str);
    
    
//    NSRange range = [canlendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
//    NSUInteger numberOfDaysInMonth = range.length;
    
    NSMutableArray *nowYearArr = [NSMutableArray array];
    
    
    for (int i = 0;i < 3;i ++) {
        [nowYearArr addObject:[NSString stringWithFormat:@"%ld年",nowY + i]];
    }
    self.yearArr = nowYearArr;
    [self.pickerViewDataArr addObject:self.yearArr];
    
    
    NSMutableArray *allDateAndWeekArr = [NSMutableArray array];
    
    
    
    NSMutableArray *arr1 = [self getDateArrWithYear:@"" orDate:date];
    [allDateAndWeekArr addObject:arr1];
    
    [self.nowAllYearDateHourMinArr addObject:arr1];
    
    for (int i = 1;i < nowYearArr.count;i ++) {
        NSString *year = nowYearArr[i];
        NSMutableArray *Arr1 = [self getDateArrWithYear:[year substringToIndex:4] orDate:nil];
        [allDateAndWeekArr addObject:Arr1];
    }
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//
//
//    NSDate *Date0 = [datePicker date];
//
//    NSTimeInterval interval = 60 * 60 * 2;
//    NSString *titleString = [dateFormatter stringFromDate:[Date0 initWithTimeInterval:interval sinceDate:Date0]];

    
    
    
    self.dateAndWeekArr = allDateAndWeekArr;
    
    [self.pickerViewDataArr addObject:self.dateAndWeekArr];
    
    NSMutableArray *allhourArr = [NSMutableArray array];
    
    NSMutableArray *todayHourArr = [NSMutableArray array];
    for (NSInteger hour = nowH;hour < 24;hour ++) {
        [todayHourArr addObject:[NSString stringWithFormat:@"%02ld时",hour]];
    }
    [allhourArr addObject:todayHourArr];
    self.nowHourArr = todayHourArr;
    

    for (int i = 1;i < nowYearArr.count ;i ++) {
        NSMutableArray *hourArr = [NSMutableArray array];
        for (int i = 0;i < 24;i ++) {
            NSString *str = [NSString stringWithFormat:@"%02d时",i];
            [hourArr addObject:str];
            
        }
        [allhourArr addObject:hourArr];
    }
    
    
    

    self.hourArr = allhourArr;
    
    [self.pickerViewDataArr addObject:self.hourArr];

    
    
    NSMutableArray *allMinArr = [NSMutableArray array];
    
    NSMutableArray *todayMinArr = [NSMutableArray array];
    if (nowF >=30) {
//
//        if (nowH == 23) {
//
//        }else{
//
//            [todayHourArr removeObjectAtIndex:0];
//        }
//
//
//
//
        todayMinArr = @[@"30分"].mutableCopy;
    }else{
        todayMinArr = @[@"00分",@"30分"].mutableCopy;
    }
//    todayMinArr = @[@"00分",@"30分"].mutableCopy;

    
    
    self.nowHourArr = todayHourArr;
    self.nowMinArr = todayMinArr;
    
    self.otherHourArr = self.hourArr[1];
    self.otherMinArr = @[@"00分",@"30分"].mutableCopy;
    
    [allMinArr addObject:todayMinArr];
    for (int i = 1;i < nowYearArr.count;i ++) {
        NSMutableArray *minArr = @[@"00分",@"30分"].mutableCopy;
        [allMinArr addObject:minArr];
    }
    
    
    
    self.minArr = allMinArr;
    
    [self.pickerViewDataArr addObject:self.minArr];

   
    NSLog(@"%@",self.pickerViewDataArr);
    
    
    
//    if (self.startDate) {
//
//    }
    
}

- (BOOL)compareWithDate:(NSDate*)bDate{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *now = [NSDate date];
    if (self.startDate) {
        now = self.startDate;
    }
    NSTimeZone *zone = [NSTimeZone systemTimeZone];//设置时区
    NSInteger interval = [zone secondsFromGMTForDate: now];
    NSDate *localDate = [now  dateByAddingTimeInterval: interval];
  
    
    NSInteger endInterval = [zone secondsFromGMTForDate: bDate];
    NSDate *end = [bDate dateByAddingTimeInterval: endInterval];
    
    NSComparisonResult result = [localDate compare:end];
    NSLog(@"the result---%ld",(long)result);
    if (result == 1)
    {

        ///过期
        return YES;
        
    }else if (result == -1){
        
//        [SVProgressHUD showErrorWithStatus:@"请选择正确的时间"];
        ///未过期
        return NO;
        
    }else{
//        NSUInteger voteCountTime = ([localDate timeIntervalSinceDate:end]) / 3600 / 24/365;
//
//        NSString *timeStr = [NSString stringWithFormat:@"%lu", (unsigned long)voteCountTime];
        ///时间一致
        return YES;
    }



}



- (void)setCurrentTime:(NSString *)currentTime{
    _currentTime = currentTime;
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    // 设置日期格式
    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
    // 要转换的日期字符串
    //    NSString *dateString1 = @"2011-05-03 23:11:40";
    // NSDate形式的日期
    NSDate *date =[formatter1 dateFromString:currentTime];
    
    if ([self compareWithDate:date]) {
        return;
    }
    
    
    NSCalendar * canlendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents * components = [canlendar components:unitFlags fromDate:date];
    NSInteger nowY = [components year];
    NSInteger nowM = [components month];
    NSInteger nowD = [components day];
    NSInteger nowH = [components hour];
    NSInteger nowF = [components minute];
    NSInteger selectYear  = 0;
    NSArray *yearArr = self.pickerViewDataArr[0];
    for (int i = 0;i <yearArr.count;i ++) {
        NSString *year = yearArr[i];
        year = [year substringToIndex:4];
        if (nowY == year.integerValue) {
            
            [self.pickTimeView selectRow:i inComponent:0 animated:YES];
            
            [self.pickTimeView reloadComponent:1];
            [self.pickTimeView reloadComponent:2];
            [self.pickTimeView reloadComponent:3];
            selectYear = i;
            self.selectRow0 = i;
            
        }
    }
    
    NSString *selecDateStr = [NSString stringWithFormat:@"%ld月%ld日",nowM,nowD];
    
    NSArray *monthArr =self.pickerViewDataArr[1][selectYear];
    
    for (int i = 0;i < monthArr.count;i ++) {
        NSString *str = monthArr[i];
        str = [str componentsSeparatedByString:@" "].firstObject;
        if ([str isEqualToString:selecDateStr]) {
            [self.pickTimeView selectRow:i inComponent:1 animated:YES];
            self.selectRow1 = i;
            [self.pickTimeView reloadComponent:2];
            [self.pickTimeView reloadComponent:3];

        }
    }
    
    if (self.selectRow0 == 0 &&self.selectRow1 == 0) {
        for (int i = 0;i < self.nowHourArr.count;i ++) {
            NSString *hour = self.nowHourArr[i];
            if ([[hour substringToIndex:hour.length - 1] integerValue] == nowH) {
                [self.pickTimeView selectRow:i inComponent:2 animated:YES];
                self.selectRow2 = i;
                 [self.pickTimeView reloadComponent:3];
            }
        }
    }else{
        for (int i = 0;i < self.otherHourArr.count;i ++) {
            NSString *hour = self.otherHourArr[i];
            if ([[hour substringToIndex:hour.length - 1] integerValue] == nowH) {
                [self.pickTimeView selectRow:i inComponent:2 animated:YES];
                self.selectRow2 = i;
                 [self.pickTimeView reloadComponent:3];
            }
        }
    }
    
    if (self.selectRow0 ==0 &&self.selectRow1 == 0&&self.selectRow2 == 0) {
        for (int i = 0;i < self.nowMinArr.count;i ++) {
            NSString *min = self.nowMinArr[i];
            if ([[min substringToIndex:min.length - 1] integerValue] == nowF) {
                [self.pickTimeView selectRow:i inComponent:3 animated:YES];
                self.selectRow3 = i;
                 
            }
        }
    }else{
        for (int i = 0;i < self.otherMinArr.count;i ++) {
            NSString *min = self.otherMinArr[i];
            if ([[min substringToIndex:min.length - 1] integerValue] == nowF) {
                [self.pickTimeView selectRow:i inComponent:3 animated:YES];
                self.selectRow3 = i;
                 
            }
        }
    }
    
    
    
    
//    NSArray *hourArr =self.pickerViewDataArr[2][selectYear];
//    for (int i = 0;i < hourArr.count;i ++) {
//        NSString *hour = hourArr[i];
//        hour =[hour substringToIndex:hour.length - 1];
//        
//        if (nowH == hour.integerValue) {
//            [self.pickTimeView selectRow:i inComponent:2 animated:YES];
//
//        }
//    }

    
    
    
    
    
    
    
    
    
    
}
- (NSMutableArray *)getDateArrWithYear:(NSString *)year  orDate:(NSDate *)date{
    NSMutableArray *arr = [NSMutableArray array];
    if (date) {
        
        
        NSCalendar * canlendar = [NSCalendar currentCalendar];
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents * components = [canlendar components:unitFlags fromDate:date];
        NSInteger nowY = [components year];
        NSInteger nowM = [components month];
        NSInteger nowD = [components day];



        for (NSInteger month = nowM;month <= 12;month ++) {
            NSInteger monthLenght = [self howManyDaysInThisYear:nowY withMonth:month];
            
            if (month == nowM) {
                for (NSInteger day = nowD;day <monthLenght; day ++) {
                    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%ld",nowY,month,day];
                    NSString *weekStr = [self getWeekWithDate:dateStr];
                    NSString *dateAndWeek = [NSString stringWithFormat:@"%ld月%ld日 %@",month,day,weekStr];
                    [arr addObject:dateAndWeek];
                }
            }else{
                for (NSInteger day = 1;day <=monthLenght; day ++) {
                    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%ld",nowY,month,day];
                    NSString *weekStr = [self getWeekWithDate:dateStr];
                    NSString *dateAndWeek = [NSString stringWithFormat:@"%ld月%ld日 %@",month,day,weekStr];
                    [arr addObject:dateAndWeek];
                }
            }
        }
        
    }else{
        
        for (int month = 1;month <= 12;month ++) {
            NSInteger monthLenght = [self howManyDaysInThisYear:year.integerValue withMonth:month];
            for (int day = 1;day <= monthLenght;day ++) {
                NSString *dateStr = [NSString stringWithFormat:@"%@-%d-%d",year,month,day];
                NSString *weekStr = [self getWeekWithDate:dateStr];
                NSString *dateAndWeek = [NSString stringWithFormat:@"%d月%d日 %@",month,day,weekStr];
                [arr addObject:dateAndWeek];
            }
        }
        
    }
    return arr;
}


- (NSMutableArray *)getDateArr:(NSDate *)date{
    
    NSMutableArray *arr = [NSMutableArray array];
    
    NSCalendar * canlendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents * components = [canlendar components:unitFlags fromDate:date];
    
    NSInteger nowY = [components year];
    NSInteger nowM = [components month];
    NSInteger nowD = [components day];
    NSInteger nowH = [components hour];
    NSInteger nowF = [components minute];
    NSInteger nowW= [components weekday];
    
    for (int i = nowM;i < 12;i ++) {
        NSInteger monthLenght = [self howManyDaysInThisYear:nowY withMonth:i];
        
        for (int i = 1;i <=monthLenght; i ++) {
            
        }
    }
    
    
    
    
    
    return arr;
}

#pragma mark ----------获取星期几
- (NSString *)getWeekWithDate:(NSString *)dateStr{
    
    

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//
    format.dateFormat = @"yyyy-MM-dd";
//
//    NSString *dateString = [format stringFromDate:date];

//    NSString *dateStr = [NSString str]
    if ([dateStr isEqualToString:[format stringFromDate:[NSDate date]]]) {
        return @"今天";
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitWeekday;
    
    
    
    
    
    comps = [calendar components:unitFlags fromDate:[format dateFromString:dateStr]];
    
    NSString *week = @"";
    switch (comps.weekday) {
        case 1:week = @"星期天";break;
        case 2:week = @"星期一";break;
        case 3:week = @"星期二";break;
        case 4:week = @"星期三";break;
        case 5:week = @"星期四";break;
        case 6:week = @"星期五";break;
        case 7:week = @"星期六";break;
        default:break;
    }
    return week;
}

- (NSString *)getWeekWith:(NSInteger )week{
    NSString *weekDayStr;
    switch(week) {
        case 1:
            weekDayStr =@"星期日";
            break;
        case 2:
            weekDayStr =@"星期一";
            break;
        case 3:
            weekDayStr =@"星期二";
            break;
        case 4:
            weekDayStr =@"星期三";
            break;
        case 5:
            weekDayStr =@"星期四";
            break;
        case 6:
            weekDayStr =@"星期五";
            break;
        case 7:
            weekDayStr =@"星期六";
            break;
        default:
            weekDayStr =@"";
            break;
    }
    return weekDayStr;
}

#pragma mark - 获取某年某月的天数
- (NSInteger)howManyDaysInThisYear:(NSInteger)year withMonth:(NSInteger)month{
  if((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12))
    return 31 ;
 
  if((month == 4) || (month == 6) || (month == 9) || (month == 11))
    return 30;
 
  if((year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3))
  {
    return 28;
  }
 
  if(year % 400 == 0)
    return 29;
 
  if(year % 100 == 0)
    return 28;
 
  return 29;
}




- (void)getData{
    /*
     获取时间数据分为两种情况，一种是常规数据，如一个月28/29/30/31天，一天24小时,一小时60分钟等，这个数据很好获取
     另一种情况是当前的数据，当前时间数据比较复杂，前提条件：分钟只需要取10钟一间隔得数据即：0、10、20、30、40、50，这样获取数据的时候需要在当前时间加10分钟，这样的话 在50~59分，小时数据是没有当前的小时值可选的；在23时50~59分，当前天数是不可选的；在每月的最后一天和每年的最后一天都有类似的特殊情况，同时需要每个一分钟更新一次当前的时间的数据
     */
    //在当前时间加10分钟，然后获取年月日时分的值
//    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:60*10];//提前10分钟
    NSDate *date = [NSDate date];
    NSCalendar * canlendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents * components = [canlendar components:unitFlags fromDate:date];
    NSInteger nowY = [components year];
    NSInteger nowM = [components month];
    NSInteger nowD = [components day];
    NSInteger nowH = [components hour];
    NSInteger nowF = [components minute];
    //给当前值赋值--这些值主要是用于时间选择器的第一次打开时显示当前时间
    self.defaultYear = [components year];
    self.defaultMonth = [components month];
    self.defaultDay = [components day];
    self.defaultHour = [components hour];
    NSLog(@"%ld",[components minute]);
    self.defaultMinute = ([components minute]/10)*10 ;
    //获取当前月的天数
    NSRange range = [canlendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    NSUInteger numberOfDaysInMonth = range.length;
    NSMutableArray * nowPickerViewDataArr0 = [[NSMutableArray alloc] init];
    NSMutableArray * nowPickerViewDataArr1 = [[NSMutableArray alloc] init];
    NSMutableArray * nowPickerViewDataArr2 = [[NSMutableArray alloc] init];
    NSMutableArray * nowPickerViewDataArr3 = [[NSMutableArray alloc] init];
    NSMutableArray * nowPickerViewDataArr4 = [[NSMutableArray alloc] init];
    //获取当前分钟数
    if (nowF >= 50) {//大于50分到59之间分钟数需要特殊处理
        self.defaultMinute = 0;
        self.defaultHour+=1;
        if (self.defaultHour == 24) {
            self.defaultHour = 0;
        }
        for (int i = 0; i < 6; i++) {
            [nowPickerViewDataArr4 addObject:[NSNumber numberWithInteger:i*10]];
        }
    }else{//小于50分，则只获取当前可选的分钟值
        for (NSInteger i = self.defaultMinute/10; i < 6; i++) {
            [nowPickerViewDataArr4 addObject:[NSNumber numberWithInteger:i*10]];
        }
    }
    //获取当前小时数
    if (nowH >= 23&&nowH>=50) {//23点50分到59之间，当前小时数需要特殊处理
        self.defaultHour+=1;
        self.defaultDay+=1;
        if (self.defaultDay >numberOfDaysInMonth) {
            self.defaultDay = 1;
        }
        for (int i = 0; i < 24; i++) {
            [nowPickerViewDataArr3 addObject:[NSNumber numberWithInteger:i]];
        }
    }else{//
        for (NSInteger i = self.defaultHour; i < 24; i++) {
            [nowPickerViewDataArr3 addObject:[NSNumber numberWithInteger:i]];
        }
    }
    //获取当前日数
    if (nowD >= numberOfDaysInMonth&&nowH >= 23&&nowH>=50) {//每月最后一天23点50分到59之间，当前小时数需要特殊处理
        self.defaultDay+=1;
        self.defaultMonth+=1;
        if (self.defaultMonth >12) {
            self.defaultMonth = 1;
        }
        for (int i = 1; i <= numberOfDaysInMonth; i++) {
            [nowPickerViewDataArr2 addObject:[NSNumber numberWithInteger:i]];
        }
    }else{//
        for (NSInteger i = self.defaultDay; i <= numberOfDaysInMonth; i++) {
            [nowPickerViewDataArr2 addObject:[NSNumber numberWithInteger:i]];
        }
    }
    //获取当前月份数
    if (nowM >= 12&&nowD >= numberOfDaysInMonth&&nowH >= 23&&nowH>=50) {//每年12月最后一天23点50分到59之间，当前小时数需要特殊处理
        self.defaultMonth+=1;
        self.defaultYear+=1;
        if (self.defaultYear >nowY) {
            self.defaultYear = nowY+1;
        }
        for (int i = 1; i <= 12; i++) {
            [nowPickerViewDataArr1 addObject:[NSNumber numberWithInteger:i]];
        }
    }else{//
        for (NSInteger i = self.defaultMonth; i <= 12; i++) {
            [nowPickerViewDataArr1 addObject:[NSNumber numberWithInteger:i]];
        }
    }
    //获取年份
    for (int i = 0; i < 3; i++) {
        [nowPickerViewDataArr0 addObject:[NSNumber numberWithInteger:i+self.defaultYear]];
    }
    //将当前时间的数据存到数组
    [self.nowPickerViewDataArr addObject:nowPickerViewDataArr0];
    [self.nowPickerViewDataArr addObject:nowPickerViewDataArr1];
    [self.nowPickerViewDataArr addObject:nowPickerViewDataArr2];
    [self.nowPickerViewDataArr addObject:nowPickerViewDataArr3];
    [self.nowPickerViewDataArr addObject:nowPickerViewDataArr4];
    //获取常规数值
    NSMutableArray * pickerViewDataArr1 = [[NSMutableArray alloc] init];
    NSMutableArray * pickerViewDataArr2 = [[NSMutableArray alloc] init];
    NSMutableArray * pickerViewDataArr3 = [[NSMutableArray alloc] init];
    NSMutableArray * pickerViewDataArr4 = [[NSMutableArray alloc] init];
    //分钟
    for (int i = 0; i < 6; i++) {
        [pickerViewDataArr4 addObject:[NSNumber numberWithInteger:i*10]];
    }
    //小时
    for (NSInteger i = 0; i < 24; i++) {
        [pickerViewDataArr3 addObject:[NSNumber numberWithInteger:i]];
    }
    //天数
    for (NSInteger i = 1; i <= numberOfDaysInMonth; i++) {
        [pickerViewDataArr2 addObject:[NSNumber numberWithInteger:i]];
    }
    //月数
    for (NSInteger i = 1; i <= 12; i++) {
        [pickerViewDataArr1 addObject:[NSNumber numberWithInteger:i]];
    }
    [self.pickerViewDataArr addObject:nowPickerViewDataArr0];
    [self.pickerViewDataArr addObject:pickerViewDataArr1];
    [self.pickerViewDataArr addObject:pickerViewDataArr2];
    [self.pickerViewDataArr addObject:pickerViewDataArr3];
    [self.pickerViewDataArr addObject:pickerViewDataArr4];
}


- (void)createSubViews{
    _selectTimeView = [[UIView alloc]initWithFrame:CGRectMake(0, Screen_Height - Scale_W(554/2) - Safe_TabBar, Screen_Width, Scale_W(554/2) + Safe_TabBar)];
    _selectTimeView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_selectTimeView];
    
    _selectTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(Scale_W(100), Scale_W(30), Screen_Width - Scale_W(200), Scale_W(20))];
    _selectTimeLabel.textColor = [UIColor blackColor];
    _selectTimeLabel.font = RegularFontX(20);
    _selectTimeLabel.textAlignment = NSTextAlignmentCenter;
    [_selectTimeView addSubview:_selectTimeLabel];
    
    if (self.type == SelectEndTime) {
        _selectTimeLabel.text = @"请选择结束时间";
    }else{
        _selectTimeLabel.text = @"请选择开始时间";
    }
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(Scale_W(15), Scale_W(137/2), Scale_W(692/2), 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [_selectTimeView addSubview:lineView];
    
    
    
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight; // 圆角位置，全部位置
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:_selectTimeView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(Scale_W(33/2), Scale_W(33/2))];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _selectTimeView.bounds;
    maskLayer.path = path.CGPath;
    _selectTimeView.layer.mask = maskLayer;
    
    
    _cancleTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, Scale_W(68/2), Scale_W(145/2), Scale_W(12))];
    [_cancleTimeBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancleTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _cancleTimeBtn.titleLabel.font = RegularFontX(12);
    [_cancleTimeBtn addTarget:self action:@selector(cancleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_selectTimeView addSubview:_cancleTimeBtn];
    
    _confirmTimeBtn = [[UIButton alloc]initWithFrame:CGRectMake(Screen_Width - Scale_W(145/2), Scale_W(62/2), Scale_W(145/2), Scale_W(16))];
    
    [_confirmTimeBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmTimeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _confirmTimeBtn.titleLabel.font = RegularFontX(16);
    [_confirmTimeBtn addTarget:self action:@selector(confrimBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_selectTimeView addSubview:_confirmTimeBtn];
    
    
    
    _pickTimeView = [[UIPickerView alloc]initWithFrame:CGRectMake(Scale_W(43/2), Scale_W(243/2), Scale_W(707/2), Scale_W(182/2))];
    _pickTimeView.delegate = self;
    _pickTimeView.dataSource = self;
    [_selectTimeView addSubview:_pickTimeView];
    
    
    
    
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(Scale_W(43/2), Scale_W(263/2), Scale_W(664/2), Scale_W(182/2))];
    
    //设置地区: zh-中国
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    
    //设置日期模式(Displays month, day, and year depending on the locale setting)
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    // 设置当前显示时间
    [datePicker setDate:[NSDate date] animated:YES];
    // 设置显示最大时间（此处为当前时间）
    //    [datePicker setMaximumDate:[NSDate date]];
    
    
    //设置时间格式
    
    //监听DataPicker的滚动
    [datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
    self.datePicker = datePicker;
    
//    [_selectTimeView addSubview:datePicker];
    
    //设置时间输入框的键盘框样式为时间选择器
    //    self.timeTextField.inputView = datePicker;
}
- (void)cancleBtnClick:(UIButton *)btn{
    [self removeFromSuperview];
}
- (void)confrimBtnClick:(UIButton *)btn{
    [self removeFromSuperview];
    
//   NSMutableArray *arr =  [self getDateArrWithYear:@"2019" orDate:nil];
//    NSLog(@"%@",arr);
//    NSLog(@"%@",arr);
    
    NSString * timeString = @"";
       for (int i =0; i < 4; i++) {
           NSInteger temprow = [self.pickTimeView selectedRowInComponent:i];
           UILabel * templable = (UILabel*)[self.pickTimeView viewForRow:temprow forComponent:i];
           //个位数的加零
//           NSInteger value = [templable.text integerValue];
//           NSString * tempString;
           
           timeString = [timeString stringByAppendingString:templable.text];
//           if (value < 10&&i>0) {
//               tempString = [NSString stringWithFormat:@"0%ld",value];
//           }else{
//               tempString = [NSString stringWithFormat:@"%ld",value];
//           }
//           if (i== 0) {
//               timeString = tempString;
//           }else if(i == 1||i == 2){
//               timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"-%@",tempString]];
//           }else{
//               timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@" %@",tempString]];
//           }
       }
    
    NSLog(@"%@",timeString);

    
     NSArray *arr = [timeString componentsSeparatedByString:@" "];
    
    NSString *year = arr.firstObject;
    NSString *time = arr.lastObject;
   time = [time substringFromIndex:3];
    timeString = [year stringByAppendingString:time];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    // 设置日期格式
    [formatter1 setDateFormat:@"yyyy年MM月dd日HH时mm分"];
    // 要转换的日期字符串
//    NSString *dateString1 = @"2011-05-03 23:11:40";
    // NSDate形式的日期
    NSDate *date =[formatter1 dateFromString:timeString];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString2 = [formatter2 stringFromDate:date];
    NSLog(@"%@",dateString2);
    self.callBack(dateString2);
}
- (void)dateChange:(UIDatePicker *)datePicker {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //设置时间格式
    formatter.dateFormat = @"yyyy年 MM月 dd日";
    NSString *dateStr = [formatter  stringFromDate:datePicker.date];
    
    NSLog(@"%@",dateStr);
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return [self.pickerViewDataArr[0] count];
    } else if(component == 1){
        return [self.pickerViewDataArr[1][self.selectRow0] count];
//        if (self.selectRow0 == 0) {
//            return [self.nowPickerViewDataArr[1] count];
//        } else {
//            return [self.pickerViewDataArr[1] count];
//        }
    }else if (component ==2){
        if (self.selectRow0 == 0&&self.selectRow1 == 0) {
            return self.nowHourArr.count;
        } else {
            return self.otherHourArr.count;
        }
    }else{
        if (self.selectRow2 == 0&&self.selectRow1 == 0&&self.selectRow0 == 0) {
            return self.nowMinArr.count;
        } else {
            return self.otherMinArr.count;
        }
    }
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.pickerViewDataArr.count;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component == 0) {
        return Scale_W(182/2);
    }else if (component == 1){
        return Scale_W(247/2);
    }else if (component == 2){
        return Scale_W(166/2);
    }else{
        return Scale_W(113/2);
    }
//    return Screen_Width/self.pickerViewDataArr.count;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return Scale_W(31);
}
-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    //添加一个label
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:component].width, Scale_W(31))];
    label.textColor = [UIColor blackColor];
    label.font = RegularFontX(13);
    label.textAlignment = NSTextAlignmentLeft;
    //对每一列都需要做特殊和非特殊的判断，一遍给到正确的值
    if (component == 0) {
        label.text = [NSString stringWithFormat:@"%@",self.pickerViewDataArr[0][row]];
    } else if(component == 1){
//        if (self.selectRow0 == 0) {
//            label.text = [NSString stringWithFormat:@"%@",self.nowPickerViewDataArr[1][row]];
//        } else {
            label.text = [NSString stringWithFormat:@"%@",self.pickerViewDataArr[1][self.selectRow0][row]];
//        }
    }else if (component ==2){
        if (self.selectRow0 == 0&&self.selectRow1 == 0) {
            label.text = [NSString stringWithFormat:@"%@",self.nowHourArr[row]];
        } else {
            label.text = [NSString stringWithFormat:@"%@",self.otherHourArr[row]];
        }
    }else if (component == 3){
        if (self.selectRow2 == 0&&self.selectRow1 == 0&&self.selectRow0 == 0) {
            
            label.text = [NSString stringWithFormat:@"%@",self.nowMinArr[row]];
        } else {
            label.text = [NSString stringWithFormat:@"%@",self.otherMinArr[row]];
        }
    }
    return label;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    //获取选中的列数
    self.selectRow0 = [pickerView selectedRowInComponent:0];
    self.selectRow1 = [pickerView selectedRowInComponent:1];
    self.selectRow2 = [pickerView selectedRowInComponent:2];
    self.selectRow3 = [pickerView selectedRowInComponent:3];
    //先清空之前的数据，在重新获取数据
//    self.pickerViewDataArr = nil;
//    self.nowPickerViewDataArr = nil;
    [self getData];
//    //刷新后面的列
    if (component == 0) {//选择完成后加载后面的列的数据但是不刷新当前列
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView reloadComponent:3];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        [pickerView selectRow:0 inComponent:3 animated:YES];

    } else if(component == 1){
        [pickerView reloadComponent:2];
        [pickerView reloadComponent:3];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        [pickerView selectRow:0 inComponent:3 animated:YES];
    }else if(component == 2){
        [pickerView reloadComponent:3];
        
        [pickerView selectRow:0 inComponent:3 animated:YES];
        
    }
}
@end
