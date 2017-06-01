//
//  MyViewController2.m
//  LFY_NavigationBar_Demo
//
//  Created by Dareway on 2017/6/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "MyViewController2.h"
#import "AppDelegate.h"

@interface MyViewController2 ()
@property(strong,nonatomic)UIImageView* barImageView;
@end

@implementation MyViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    // Do any additional setup after loading the view.

    //为了防止push,pop是，显示短暂的黑色
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.window.backgroundColor = [UIColor whiteColor];

    self.barImageView = self.navigationController.navigationBar.subviews.firstObject;

}

//此种导航栏的隐藏是改变图片的透明度，还可以用来做导航栏颜色根据tableView的偏移量动态改变

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _barImageView.alpha = 0 ;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _barImageView.alpha = 1 ;
    
}

@end
