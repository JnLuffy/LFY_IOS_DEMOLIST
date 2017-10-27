//
//  XLPaymentFailureHUD.m
//  XLPaymentHUDExample
//
//  Created by apple on 17/10/26.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import "XLPaymentFailureHUD.h"
static CGFloat lineWidth = 4.0f;
static CGFloat circleDuriation = 0.5f;
static CGFloat crossDuriation = 0.2f;

#define BlueColor [UIColor colorWithRed:16/255.0 green:142/255.0 blue:233/255.0 alpha:1]

@implementation XLPaymentFailureHUD
{
    CALayer *_animationLayer;

}

- (void)start {
    [self circleAnimation];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.8 * circleDuriation * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self crossAnimation1];
        
        dispatch_time_t time2 = dispatch_time(DISPATCH_TIME_NOW, 0.8 * crossDuriation * NSEC_PER_SEC);
        dispatch_after(time2, dispatch_get_main_queue(), ^{
            [self crossAnimation2];
            
        });
    });
}

-(void)hide{
    for (CALayer *layer in _animationLayer.sublayers) {
        [layer removeAllAnimations];
    }
}

+(XLPaymentFailureHUD*)showIn:(UIView*)view{
    [self hideIn:view];
    XLPaymentFailureHUD *hud = [[XLPaymentFailureHUD alloc] initWithFrame:view.bounds];
    [hud start];
    [view addSubview:hud];
    return hud;
}

+(XLPaymentFailureHUD*)hideIn:(UIView*)view{
    XLPaymentFailureHUD *hud = nil;
    for (XLPaymentFailureHUD *subView in view.subviews) {
        if ([subView isKindOfClass:[XLPaymentFailureHUD class]]) {
            [subView hide];
            [subView removeFromSuperview];
            hud = subView;
        }
    }
    return hud;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}




- (void)buildUI {
    _animationLayer = [CALayer layer];
    _animationLayer.bounds = CGRectMake(0, 0, 60, 60);
    _animationLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self.layer addSublayer:_animationLayer];

}

-(void)circleAnimation{
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = _animationLayer.bounds;
    [_animationLayer addSublayer:circleLayer];
    circleLayer.fillColor =  [[UIColor clearColor] CGColor];
    circleLayer.strokeColor  = BlueColor.CGColor;
    circleLayer.lineWidth = lineWidth;
    circleLayer.lineCap = kCALineCapRound;
    
    
    CGFloat lineWidth = 5.0f;
    CGFloat radius = _animationLayer.bounds.size.width/2.0f - lineWidth/2.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:circleLayer.position radius:radius startAngle:-M_PI/2 endAngle:M_PI*3/2 clockwise:true];
    circleLayer.path = path.CGPath;
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.duration = circleDuriation;
    circleAnimation.fromValue = @(0.0f);
    circleAnimation.toValue = @(1.0f);
    circleAnimation.delegate = self;
    [circleAnimation setValue:@"circleAnimation" forKey:@"animationName"];
    [circleLayer addAnimation:circleAnimation forKey:nil];
}


-(void)crossAnimation1{
    CGFloat a = _animationLayer.bounds.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*3./10,a*3./10)];
    [path addLineToPoint:CGPointMake(a*7.0/10,a*7./10)];
    
    CAShapeLayer *crossLabel = [CAShapeLayer layer];
    crossLabel.path = path.CGPath;
    crossLabel.fillColor = [UIColor clearColor].CGColor;
    crossLabel.strokeColor = BlueColor.CGColor;
    crossLabel.lineWidth = lineWidth;
    crossLabel.lineCap = kCALineCapRound;
    crossLabel.lineJoin = kCALineJoinRound;
    [_animationLayer addSublayer:crossLabel];
    crossLabel.backgroundColor = [UIColor greenColor].CGColor;
    
    CABasicAnimation *crossAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    crossAnimation.duration = crossDuriation;
    crossAnimation.fromValue = @(0.0f);
    crossAnimation.toValue = @(1.0f);
    crossAnimation.delegate = self;
    [crossAnimation setValue:@"crossAnimationOne" forKey:@"animationName"];
    [crossLabel addAnimation:crossAnimation forKey:nil];
    
  
}


-(void)crossAnimation2{
    CGFloat a = _animationLayer.bounds.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*7./10,a*3./10)];
    [path addLineToPoint:CGPointMake(a*3.0/10,a*7./10)];
    
    CAShapeLayer *crossLabel = [CAShapeLayer layer];
    crossLabel.path = path.CGPath;
    crossLabel.fillColor = [UIColor clearColor].CGColor;
    crossLabel.strokeColor = BlueColor.CGColor;
    crossLabel.lineWidth = lineWidth;
    crossLabel.lineCap = kCALineCapRound;
    crossLabel.lineJoin = kCALineJoinRound;
    [_animationLayer addSublayer:crossLabel];
    
    CABasicAnimation *crossAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    crossAnimation.duration = crossDuriation;
    crossAnimation.fromValue = @(0.0f);
    crossAnimation.toValue = @(1.0f);
    crossAnimation.delegate = self;
    [crossAnimation setValue:@"crossAnimationOne" forKey:@"animationName"];
    [crossLabel addAnimation:crossAnimation forKey:nil];
    
}



@end
