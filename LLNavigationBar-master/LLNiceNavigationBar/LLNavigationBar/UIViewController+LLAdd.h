//
//  UIViewController+LLAdd.h
//  LLNiceNavigationBar
//
//  Created by 雷亮 on 16/8/31.
//  Copyright © 2016年 Leiliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LLAdd)

/** 设置导航栏的状态与scrollView同步
 * @param scrollView : 滚动视图, UIScrollView、UIWebView等
 */
- (void)ll_navigationBarFollowScrollView:(UIView *)scrollView;

/** 隐藏navigationBar
 * @param hidden: YES 隐藏, NO 显示
 */
- (void)ll_setNavigationBarHidden:(BOOL)hidden;

/** 隐藏navigationBar
 * @param hidden : YES 隐藏, NO 显示
 * @param animated : YES 需要动画, NO 不需要动画
 */
- (void)ll_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end
