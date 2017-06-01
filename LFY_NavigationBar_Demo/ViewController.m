//
//  ViewController.m
//  LFY_NavigationBar_Demo
//
//  Created by Dareway on 2017/6/1.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "ViewController.h"
#import "MyViewController1.h"
#import "MyViewController2.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    UIButton *btn0 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn0.backgroundColor = [UIColor orangeColor];
    btn0.frame = CGRectMake(100, 100, 100, 50);
    [btn0 setTitle:@"导航栏隐藏1" forState:UIControlStateNormal];
    [btn0 addTarget:self action:@selector(btn0Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn0];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.backgroundColor = [UIColor blueColor];
    btn1.frame = CGRectMake(100, 300, 100, 50);
    [btn1 setTitle:@"导航栏隐藏2" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)btn0Action:(id)sender{
    //导航栏隐藏方式一
    [self.navigationController pushViewController:[MyViewController1 new] animated:YES];
}


-(void)btn1Action:(id)sender{
    //导航栏隐藏方式二
     [self.navigationController pushViewController:[MyViewController2 new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
