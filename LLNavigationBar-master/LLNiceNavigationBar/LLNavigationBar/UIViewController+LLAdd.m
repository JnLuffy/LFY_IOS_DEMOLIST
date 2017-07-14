//
//  UIViewController+LLAdd.m
//  LLNiceNavigationBar
//
//  Created by 雷亮 on 16/8/31.
//  Copyright © 2016年 Leiliang. All rights reserved.
//

#import "UIViewController+LLAdd.h"
#import "YYKitMacro.h"
#import <objc/message.h>

static CGFloat const kNavigationBarHeight = 44.f;
static NSTimeInterval const kDuration = 0.4f;

@interface UIViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIView *statusView;
@property (nonatomic, assign) BOOL isHidden;

@end

@implementation UIViewController (LLAdd)

YYSYNTH_DYNAMIC_PROPERTY_OBJECT(scrollView, setScrollView, ASSIGN, UIView *)
YYSYNTH_DYNAMIC_PROPERTY_OBJECT(panGesture, setPanGesture, RETAIN_NONATOMIC, UIPanGestureRecognizer *)
YYSYNTH_DYNAMIC_PROPERTY_OBJECT(statusView, setStatusView, RETAIN_NONATOMIC, UIView *)
YYSYNTH_DYNAMIC_PROPERTY_CTYPE(isHidden, setIsHidden, BOOL)

+ (void)load {
    static dispatch_once_t onceTokn;
    dispatch_once(&onceTokn, ^{
        Method originMethod = class_getInstanceMethod([self class], @selector(viewDidAppear:));
        Method totalMethod = class_getInstanceMethod([self class], @selector(ll_viewDidAppear:));
        method_exchangeImplementations(originMethod, totalMethod);
    });
}

- (void)ll_viewDidAppear:(BOOL)animated {
    [self ll_viewDidAppear:animated];
    if (self.statusView) {
        [self.navigationController.navigationBar bringSubviewToFront:self.statusView];
    }
}

- (void)ll_navigationBarFollowScrollView:(UIView *)scrollView {
    self.scrollView = scrollView;
    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] init];
        self.panGesture.delegate = self;
        self.panGesture.minimumNumberOfTouches = 1;
        [self.panGesture addTarget:self action:@selector(handlePanGesture:)];
        [self.scrollView addGestureRecognizer:self.panGesture];
    }
    if (!self.statusView) {
        self.statusView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
        self.statusView.alpha = 0;
        self.statusView.backgroundColor = self.navigationController.navigationBar.barTintColor;
        [self.navigationController.navigationBar addSubview:self.statusView];
        [self.navigationController.navigationBar bringSubviewToFront:self.statusView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:[self.scrollView superview]];
    NSLog(@"tanslation.y =  %f",translation);
    // 显示
    if (translation.y >= 5) {
        if (self.isHidden) {
            self.statusView.alpha = 0;
            CGRect navBarFrame = self.navigationController.navigationBar.frame;
            CGRect scrollViewFrame = self.scrollView.frame;
            navBarFrame.origin.y = 20;
            scrollViewFrame.origin.y += kNavigationBarHeight;
            scrollViewFrame.size.height -= kNavigationBarHeight;
            
            [UIView animateWithDuration:kDuration animations:^{
                self.navigationController.navigationBar.frame = navBarFrame;
                self.scrollView.frame = scrollViewFrame;
                if ([self.scrollView isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView = (UIScrollView *)self.scrollView;
                    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + kNavigationBarHeight);
                } else if ([self.scrollView isKindOfClass:[UIWebView class]]) {
                    UIWebView *webView = (UIWebView *)self.scrollView;
                    webView.scrollView.contentOffset = CGPointMake(webView.scrollView.contentOffset.x, webView.scrollView.contentOffset.y + kNavigationBarHeight);
                }
            }];
            self.isHidden = NO;
        }
    }
    // 隐藏
    if (translation.y <= -20) {
        if (!self.isHidden) {
            CGRect frame = self.navigationController.navigationBar.frame;
            CGRect scrollViewFrame = self.scrollView.frame;
            frame.origin.y = -44; // 20 - kNavigationBarHeight
            scrollViewFrame.origin.y -= kNavigationBarHeight;
            scrollViewFrame.size.height += kNavigationBarHeight;
            
            [UIView animateWithDuration:kDuration animations:^{
                self.navigationController.navigationBar.frame = frame;
                self.scrollView.frame = scrollViewFrame;
                if ([self.scrollView isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView = (UIScrollView *)self.scrollView;
                    // contentOffset:scrollview当前显示区域顶点相对于frame顶点的偏移量
                    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 64);
                } else if ([self.scrollView isKindOfClass:[UIWebView class]]) {
                    UIWebView *webView = (UIWebView *)self.scrollView;
                    webView.scrollView.contentOffset = CGPointMake(webView.scrollView.contentOffset.x, webView.scrollView.contentOffset.y - kNavigationBarHeight);
                }
            } completion:^(BOOL finished) {
                self.statusView.alpha = 1;
            }];
            self.isHidden = YES;
        }
    }
}

- (void)ll_setNavigationBarHidden:(BOOL)hidden {
    [self ll_setNavigationBarHidden:hidden animated:YES];
}

- (void)ll_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (!self.statusView) {
        self.statusView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
        self.statusView.alpha = 0;
        self.statusView.backgroundColor = self.navigationController.navigationBar.barTintColor;
        [self.navigationController.navigationBar addSubview:self.statusView];
        [self.navigationController.navigationBar bringSubviewToFront:self.statusView];
    }
    if (hidden) {
        CGRect frame = self.navigationController.navigationBar.frame;
        frame.origin.y = -24; // 20 - kNavigationBarHeight
        if (animated) {
            [UIView animateWithDuration:kDuration animations:^{
                self.navigationController.navigationBar.frame = frame;
            } completion:^(BOOL finished) {
                self.statusView.alpha = 1;
            }];
        } else {
            self.navigationController.navigationBar.frame = frame;
            self.statusView.alpha = 1;
        }
        self.isHidden = YES;
    } else {
        self.statusView.alpha = 0;
        CGRect navBarFrame = self.navigationController.navigationBar.frame;
        navBarFrame.origin.y = 20;
        if (animated) {
            [UIView animateWithDuration:kDuration animations:^{
                self.navigationController.navigationBar.frame = navBarFrame;
            }];
        } else {
            self.navigationController.navigationBar.frame = navBarFrame;
        }
        self.isHidden = NO;
    }
}

@end
