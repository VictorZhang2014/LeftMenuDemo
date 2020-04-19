# LeftMenuDemo  


左滑菜单主要实现功能的类文件是
```
BDLeftMenuView.h
BDLeftMenuView.m
``` 
![demo.jpeg](https://github.com/VictorZhang2014/LeftMenuDemo/blob/master/demo.jpeg)
![demo.gif](https://github.com/VictorZhang2014/LeftMenuDemo/blob/master/demo.gif)


## 使用方法 
如果是Objective-C，先导入头文件
```
#import "BDLeftMenuView.h"
```
如果是Swift和OC混合工程，请在Objective-C的桥接文件里导入此头文件，然后就可以在Swift中直接使用类名调用

直接调用此静态方法，会把左滑菜单添加到UIWindow上
```
[BDLeftMenuView show];
```
直接调用此静态方法，会把左滑菜单添加到你想指定的UIView上
```
[BDLeftMenuView showInView:self.view];
```
`hide`方法会自动调用，不需要主动调用
```
[BDLeftMenuView hide];
```


## 启用屏幕边缘可滑入左侧菜单
这个`self.view`表示你希望用户在哪个ViewController中的View左侧滑动时，显示左侧菜单
```
[BDLeftMenuView enableScreenEdgeDraggingInView:self.view];
```

## 动态修改左侧菜单列表信息
```
// 修改用户信息
- (void)changeUserInfo:(NSDictionary *)userInfo;

// 修改菜单列表的数据  比如：切换语言时，或者新增，或者删除列表项时
- (void)changeMenuDataList:(NSArray *)menuDataList;
```

## 左侧菜单的列表项点击事件以通知传递
```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEventLeftMenu:) name:kBDLeftMenuViewEventNotification object:nil];
```
```
- (void)onEventLeftMenu:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;

}
```


