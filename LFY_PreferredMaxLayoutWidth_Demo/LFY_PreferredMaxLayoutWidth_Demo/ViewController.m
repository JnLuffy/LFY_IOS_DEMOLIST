//
//  ViewController.m
//  LFY_PreferredMaxLayoutWidth_Demo
//
//  Created by Dareway on 2017/6/23.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *myLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _myLabel.text = @"在消除编译警告的时候，发现一个叫做Automatic Preferred Max Layout Width is not available on iOS versions prior to 8.0，几番探索终于发现是一个UILabel的";
    //1.只设置约束宽度，不设置preferredMaxLayoutWidth 且numberOfLine = 0;

    
    
    //2.只设置preferredMaxLayoutWidth
    _myLabel.preferredMaxLayoutWidth = 500;

    
    //3. 同时设置 preferrredMaxLayoutWidth 和 约束宽度（能计算出的）
    //preferredMaxLayoutWidth < 约束的宽度时， 计算出的行高大约实际高度
    //preferredMaxLayoutWidth > 约束的宽度是，计算出的行高小于实际高度


    
    
    
//    preferredMaxLayoutWidth 的作用是用于计算UILable的高度,当
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
