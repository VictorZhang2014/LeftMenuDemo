//
//  BDLeftMenuView.h
//  YueChe
//
//  Created by VictorZhang on 2020/4/19.
//  Copyright © 2020 TelaBytes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *kBDLeftMenuViewEventNotification = @"kBDLeftMenuViewEventNotification";


@interface BDLeftMenuView : UIView

+ (BDLeftMenuView *)getInstanceView;

+ (void)show;
+ (void)hide;

+ (void)showInView:(UIView *)superView;
+ (void)hideInView:(UIView *)superView;

// 启用屏幕边缘拖拽
+ (void)enableScreenEdgeDraggingInView:(UIView *)edgeSelfView;

// 修改用户信息
- (void)changeUserInfo:(NSDictionary *)userInfo;

// 修改菜单列表的数据  比如：切换语言时，或者新增，或者删除列表项时
- (void)changeMenuDataList:(NSArray *)menuDataList;

@end

NS_ASSUME_NONNULL_END
