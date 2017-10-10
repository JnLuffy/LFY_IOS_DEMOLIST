//
//  ViewController.m
//  Test_Method_exchangeImplementions
//
//  Created by Dareway on 2017/10/10.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self methoExchange1];
    [self methoExchange1];
    [self method1];
    [self method2];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)method1{
    NSLog(@"This is method 1 implemention");
}

-(void)method2{
    NSLog(@"This is method 2 implemention");
}



/**
   Questions:
   1.这个方法执行2个会有什么情况？ 又换回来了，所以使用dispatch_onces 保证只交换一次
   2.带参数的方法如何交换，是不是参数必须相等？
   3.能否让这2个方法自己交换？http://blog.sina.com.cn/s/blog_9d25acc60102vts9.html
 
 
 */
-(void)methodExchange{
    Class class = [self class];
    Method method1 = class_getInstanceMethod(class, @selector(method1));
    Method method2 = class_getInstanceMethod(class, @selector(method2));
    method_exchangeImplementations(method1, method2);
}


//the question1 solution
-(void)methoExchange1{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        Method method1 = class_getInstanceMethod(class, @selector(method1));
        Method method2 = class_getInstanceMethod(class, @selector(method2));
        method_exchangeImplementations(method1, method2);
    });
}



@end
