//
//  HSXSelectTimeView.h
//  SuiXing
//
//  Created by 这是C先生 on 2020/3/23.
//  Copyright © 2020 这是C先生. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, Type3)
{
    //以下是枚举成员
    SelectStartTime = 0,
    SelectEndTime = 1,
};


@interface HSXSelectTimeView : UIView


/*!
 */
@property (nonatomic,copy)void (^callBack)(NSString *timeString);

- (instancetype)initWithFrame:(CGRect)frame withType:(Type3)type withDate:(NSDate *)startDate;


/*!
 */
@property (nonatomic,copy)NSString *currentTime;


@end

NS_ASSUME_NONNULL_END
