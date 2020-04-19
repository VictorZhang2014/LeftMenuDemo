//
//  BDMainNavigationBar.m
//  YueChe
//
//  Created by VictorZhang on 2020/4/19.
//  Copyright © 2020 TelaBytes. All rights reserved.
//

#import "BDMainNavigationBar.h"
#import "BDLeftMenuView.h"

@implementation BDMainNavigationBar

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self setupViewWith:rect];
}

- (void)setupViewWith:(CGRect)rect {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat leftMargin = 10;
    
    CGFloat userProfileBtnWidth = 44;
    CGFloat userProfileBtnHeight = 44;
    CGFloat userProfileBtnY = statusBarSize.height + 10;
    UIButton *userProfileBtn = [[UIButton alloc] init];
    userProfileBtn.backgroundColor = [UIColor whiteColor];
    userProfileBtn.layer.cornerRadius = userProfileBtnWidth / 2;
    userProfileBtn.frame = CGRectMake(leftMargin, userProfileBtnY, userProfileBtnWidth, userProfileBtnHeight);
    [userProfileBtn setImage:[UIImage imageNamed:@"DefaultAvatar"] forState:UIControlStateNormal];
    [userProfileBtn setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    [userProfileBtn addTarget:self action:@selector(didShowLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:userProfileBtn];
    
    /*
    UIView *btmLine = [[UIView alloc] init];
    btmLine.backgroundColor = [UIColor lightGrayColor];
    btmLine.frame = CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5);
    [self addSubview:btmLine];
    */
}

- (void)didShowLeftMenu {
    [BDLeftMenuView show];
}

@end
