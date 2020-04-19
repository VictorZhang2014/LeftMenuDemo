//
//  ViewController.m
//  YueChe
//
//  Created by VictorZhang on 2020/4/19.
//  Copyright © 2020 TelaBytes. All rights reserved.
//

#import "BDMainViewController.h"
#import "BDMainNavigationBar.h"
#import "BDLeftMenuView.h"
#import <WebKit/WebKit.h>
#import "TestViewController.h"


@interface BDMainViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) BDMainNavigationBar *navView;

@end

@implementation BDMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigatorView];
    [self setupViews];
    
    // 启用屏幕边缘拖拽出左侧菜单
    [BDLeftMenuView enableScreenEdgeDraggingInView:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEventLeftMenu:) name:kBDLeftMenuViewEventNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)setupNavigatorView {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    
    BDMainNavigationBar *navView = [[BDMainNavigationBar alloc] init];
    CGFloat navViewHeight = navBarSize.height + statusBarSize.height + 10;
    navView.frame = CGRectMake(0, 0, self.view.bounds.size.width, navViewHeight);
    [self.view addSubview:navView];
    _navView = navView;
}

- (void)setupViews {
    // 暂时用Web Map替代
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://map.baidu.com/mobile/webapp/index/index/foo=bar/vt=map"]];
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    CGRect webViewFrame = [UIScreen mainScreen].bounds;
    webViewFrame.origin.y = -105;
    webViewFrame.size.height += 105;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:webViewFrame configuration:webViewConfig];
    webView.navigationDelegate = self;
    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [webView loadRequest:urlRequest];
    [self.view insertSubview:webView belowSubview:self.navView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *js = @"document.getElementById('fis_elm__3').remove();";
    NSString *js1 = @"document.getElementById('fis_elm__4').remove();";
    NSString *js2 = @"document.getElementById('fis_elm__5').remove();";
    NSString *js3 = @"document.getElementById('fis_elm__6').remove();";
    [webView evaluateJavaScript:[NSString stringWithFormat:@"%@%@%@%@", js, js1, js2, js3] completionHandler:nil];
}

# pragma mark -- 通知事件
- (void)onEventLeftMenu:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    BOOL isUserHeader = [userInfo[@"isUserHeader"] boolValue];
    NSDictionary *data = userInfo[@"data"];
    
    TestViewController *vc = [[TestViewController alloc] init];
    if (isUserHeader) {
        vc.title = data[@"title"];
    } else {
        vc.title = data[@"title"];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

@end

