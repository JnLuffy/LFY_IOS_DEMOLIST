//
//  MyViewController1.m
//  LFY_NavigationBar_Demo
//
//  Created by Dareway on 2017/6/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "MyViewController1.h"

@interface MyViewController1 ()

@end

@implementation MyViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    // Do any additional setup after loading the view.
}

//此种方式隐藏导航栏一般应用于首页，因为此种方式会导致返回按钮消失

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    //设置状态栏的颜色（如果不需要设置，可以忽略）
    if ([[[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"] respondsToSelector:@selector(setBackgroundColor:)]) {
        [[[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"] setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    }
    
    //如果状态栏背景为浅色，应选用黑色字样式(UIStatusBarStyleDefault，默认值)；如果背景为深色，则选用白色字样式(UIStatusBarStyleLightContent)。
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
    //将状态栏的颜色改回来
    if ([[[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"] respondsToSelector:@selector(setBackgroundColor:)]) {
        [[[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"] setBackgroundColor:[UIColor blueColor]];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
