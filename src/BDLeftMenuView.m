//
//  BDLeftMenuView.m
//  YueChe
//
//  Created by VictorZhang on 2020/4/19.
//  Copyright © 2020 TelaBytes. All rights reserved.
//

#import "BDLeftMenuView.h"


#define UIScreenBounds          [UIScreen mainScreen].bounds
#define BDLeftMenuViewMaxWidth  UIScreenBounds.size.width * 0.70  // 左侧白色菜单的宽度
#define AnimationDuration       0.25

#define kCellReuseIDUserHeader  @"BDLeftMenuViewTableViewUserHeaderCellReuseID"
#define kCellReuseID            @"BDLeftMenuViewTableViewCellReuseID"


static BDLeftMenuView *_leftMenuView = nil;


@interface BDLeftMenuView ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIView *translucentView;
@property (nonatomic, weak) UIView *menuListView;

@property (nonatomic, assign) CGPoint originalMenuViewCenter;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *scrollXAxisPathes; // 滑动时X值的路径，最多只存5个

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *menuDataList;

@end

@implementation BDLeftMenuView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

+ (BDLeftMenuView *)getInstanceView {
    return _leftMenuView;
}

+ (void)show {
    _leftMenuView = [[BDLeftMenuView alloc] init];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_leftMenuView];
    [_leftMenuView addMenuPanGesture]; // 添加拖拽手势
}

+ (void)hide {
    [_leftMenuView didCloseLeftMenu];
}

+ (void)showInView:(UIView *)superView {
    _leftMenuView = [[BDLeftMenuView alloc] init];
    [superView addSubview:_leftMenuView];
    [_leftMenuView addMenuPanGesture]; // 添加拖拽手势
}

+ (void)hideInView:(UIView *)superView {
    [_leftMenuView didCloseLeftMenu];
}

// 启用屏幕边缘拖拽
+ (void)enableScreenEdgeDraggingInView:(UIView *)edgeSelfView {
    UIScreenEdgePanGestureRecognizer *edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveEdgeGesture:)];
    edgePanGesture.edges = UIRectEdgeLeft;
    [edgeSelfView addGestureRecognizer:edgePanGesture];
}

+ (void)didReceiveEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    //CGPoint translation = [gesture translationInView:gesture.view];
    if (_leftMenuView == nil) {
        [BDLeftMenuView show];
    }
}


# pragma mark -- 创建基础视图
- (void)setupViews {
    self.frame = UIScreenBounds;
    _scrollXAxisPathes = [[NSMutableArray alloc] init];
    
    CGFloat pageWidth = BDLeftMenuViewMaxWidth;
    CGFloat pageHeight = UIScreenBounds.size.height;
    
    UITapGestureRecognizer *closeMenuViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCloseLeftMenu)];
    closeMenuViewRecognizer.delegate = self;
    
    UIView *translucentView = [[UIView alloc] init];
    translucentView.backgroundColor = [UIColor blackColor];
    translucentView.frame = UIScreenBounds;
    translucentView.alpha = 0.25;
    [translucentView addGestureRecognizer:closeMenuViewRecognizer];
    [self addSubview:translucentView];
    _translucentView = translucentView;
    
    UIView *whiteLeftView = [[UIView alloc] init];
    whiteLeftView.frame = UIScreenBounds;
    [whiteLeftView addGestureRecognizer:closeMenuViewRecognizer];
    [self addSubview:whiteLeftView];
    
    UIView *menuListView = [self createMenuListViewWithFrame:CGRectMake(-pageWidth, 0, pageWidth, pageHeight)];
    [whiteLeftView addSubview:menuListView];
    _menuListView = menuListView;
    
    // 存储原始的self视图的中心点
    _originalMenuViewCenter = self.center;
    
    [self showInAnimation];
}

# pragma mark -- 关闭菜单视图
- (void)didCloseLeftMenu {
    [self hideInAnimation];
}

# pragma mark -- 点击左侧菜单屏幕事件 UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        // 如果用户点击的是UITableViewCell的话，则不处理此手势事件，应该交给UITableViewCell自己处理
        return NO;
    }
    return YES;
}


# pragma mark -- 添加左侧菜单拖拽手势
- (void)addMenuPanGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePanGesture:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [self.menuListView.superview addGestureRecognizer:panGesture];
}

- (void)didReceivePanGesture:(UIPanGestureRecognizer *)gesture {
    // 在指定的View上计算转换出它的坐标值
    CGPoint translation = [gesture translationInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self addOriginXValue:@(gesture.view.frame.origin.x)];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self addOriginXValue:@(gesture.view.frame.origin.x)];
    }  else {
        // gesture.state == UIGestureRecognizerStateEnded ||
        // gesture.state == UIGestureRecognizerStateCancelled ||
        // gesture.state ==  UIGestureRecognizerStateFailed
        // 判断最后一次是往左滑动，还是往右滑动
        CGFloat firstXValue = [[self.scrollXAxisPathes lastObject] floatValue];
        CGFloat lastXValue = [[self.scrollXAxisPathes firstObject] floatValue];
        if (firstXValue == 0 && lastXValue == 0) {
            // to do nothing
        } else if (firstXValue == lastXValue) {
            [self showInAnimationWhenScrolling];
        } else if (firstXValue > lastXValue) {
            [self showInAnimationWhenScrolling];
        } else {
            [self hideInAnimation];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // center回到原始点
            gesture.view.center = self.originalMenuViewCenter;
            [gesture setTranslation:CGPointZero inView:gesture.view];
        });
        // 置空X值得数组
        _scrollXAxisPathes = [[NSMutableArray alloc] init];
    }
    
    // 让左侧菜单跟着用户手指拖拽的走
    CGFloat centerX = gesture.view.center.x + translation.x;
    if (centerX > self.originalMenuViewCenter.x) {
        centerX = self.originalMenuViewCenter.x; // 防止向右拖拽时超出左侧边缘
    }
    gesture.view.center = CGPointMake(centerX, gesture.view.center.y);
    [gesture setTranslation:CGPointZero inView:gesture.view];
}

- (void)addOriginXValue:(NSNumber *)number {
    // 最多只存5个滑动时X轴的值
    if (self.scrollXAxisPathes.count <= 5) {
        [self.scrollXAxisPathes addObject:number];
    } else {
        [self.scrollXAxisPathes removeObjectAtIndex:0];
        [self.scrollXAxisPathes addObject:number];
    }
}

- (UIView *)createMenuListViewWithFrame:(CGRect)viewFrame {
    UIView *listView = [[UIView alloc] initWithFrame:viewFrame];
    listView.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.gestureRecognizers = nil;
    [listView addSubview:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIDUserHeader];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseID];
    _tableView = tableView;
    
    _userInfo = @{ @"icon": @"TestUserAvatar", @"title": @"187****0897"};
    _menuDataList = @[
                      @{@"type": @(1), @"icon": @"OrderBlueIcon", @"title": @"行程订单"},
                      @{@"type": @(2), @"icon": @"ServiceBlueIcon", @"title": @"客服中心"},
                      @{@"type": @(2), @"icon": @"FeedbackBlueIcon", @"title": @"问题反馈"},
                      @{@"type": @(3), @"icon": @"SettingBlueIcon", @"title": @"设置"}
                    ];
    
    return listView;
}

- (void)changeUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

// 修改菜单列表的数据  比如：切换语言时，或者新增，或者删除列表项时
- (void)changeMenuDataList:(NSArray *)menuDataList {
    _menuDataList = menuDataList;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showInAnimationWhenScrolling {
    // 用户左右滑动菜单时，动画显示左侧菜单
    [UIView animateWithDuration:AnimationDuration animations:^{
        CGRect menuListViewFrame = self.menuListView.superview.frame;
        menuListViewFrame.origin.x = 0;
        self.menuListView.superview.frame = menuListViewFrame;
    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
}

- (void)showInAnimation {
    [UIView animateWithDuration:AnimationDuration animations:^{
        self.translucentView.alpha = 0.25;
    
        // 动画显示左侧菜单
        CGRect menuListViewFrame = self.menuListView.frame;
        menuListViewFrame.origin.x = 0;
        self.menuListView.frame = menuListViewFrame;
    }];
}

- (void)hideInAnimation {
    //_translucentView.alpha = 0.25;
    [UIView animateWithDuration:AnimationDuration animations:^{
        self.translucentView.alpha = 0.0;
        
        // 动画隐藏左侧菜单
        CGRect menuListViewFrame = self.menuListView.frame;
        menuListViewFrame.origin.x = -menuListViewFrame.size.width;
        self.menuListView.frame = menuListViewFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.translucentView removeFromSuperview];
            self.translucentView = nil;

            // 删除当前视图
            [_leftMenuView removeFromSuperview];
            _leftMenuView = nil;
        }
    }];
}

- (void)dealloc {
    NSLog(@"BDLeftMenuView has been deallocated!");
}


# pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.menuDataList.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 170;
    } else if (indexPath.section == 1) {
        return 70;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIDUserHeader];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseIDUserHeader];
        }
        cell.imageView.image = [UIImage imageNamed:self.userInfo[@"icon"]];
        cell.imageView.layer.cornerRadius = 35;
        cell.imageView.layer.masksToBounds = YES;
        cell.textLabel.text = self.userInfo[@"title"];
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIDUserHeader];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseID];
        }
        NSDictionary *dict = [self.menuDataList objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:dict[@"icon"]];
        cell.textLabel.text = dict[@"title"];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

# pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBDLeftMenuViewEventNotification object:nil userInfo:@{@"isUserHeader":@(YES), @"data":self.userInfo}];
        [self didCloseLeftMenu];
    } else if (indexPath.section == 1) {
        NSDictionary *dict = [self.menuDataList objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBDLeftMenuViewEventNotification object:nil userInfo:@{@"isUserHeader":@(NO), @"data":dict}];
        [self didCloseLeftMenu];
    }
}

@end
