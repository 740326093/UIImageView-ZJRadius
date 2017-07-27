//
//  UIImageView+ZJRadius.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "UIImageView+ZJRadius.h"
#import <objc/runtime.h>

@implementation UIImageView (ZJRadius)
static bool _needClipsToBounds;

+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector1 = @selector(setClipsToBounds:);
        SEL swizzledSelector1 = @selector(ZJ_setClipsToBounds:);
        
        Method originalMethod1 = class_getInstanceMethod(class, originalSelector1);
        Method swizzledMethod1 = class_getInstanceMethod(class, swizzledSelector1);
        
        BOOL didAddMethod1 = class_addMethod(class, originalSelector1, method_getImplementation(swizzledMethod1), method_getTypeEncoding(swizzledMethod1));
        
        if (didAddMethod1) {
            class_replaceMethod(class, swizzledSelector1, method_getImplementation(originalMethod1), method_getTypeEncoding(originalMethod1));
        } else {
            method_exchangeImplementations(originalMethod1, swizzledMethod1);
        }
        
        
        SEL originalSelector2 = @selector(setImage:);
        SEL swizzledSelector2 = @selector(ZJ_setImage:);
        
        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
        
        BOOL didAddMethod2 = class_addMethod(class, originalSelector2, method_getImplementation(swizzledMethod2), method_getTypeEncoding(swizzledMethod2));
        
        if (didAddMethod2) {
            class_replaceMethod(class, swizzledSelector2, method_getImplementation(originalMethod2), method_getTypeEncoding(originalMethod2));
        } else {
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
         
    });
}


- (void)ZJ_setClipsToBounds:(BOOL)clipsToBounds{
    _needClipsToBounds = clipsToBounds;
    
    if (self.layer.cornerRadius <= 0) { //若圆角为0 则允许maskT‚‚oBounds
        [self ZJ_setClipsToBounds:clipsToBounds];
    }
}


- (void)ZJ_setImage:(UIImage *)image{
    
    if (self.layer.cornerRadius > 0 && _needClipsToBounds) {
        [self ZJ_maskImage:image];
    } else {
        [self ZJ_setImage:image];
    }
}


- (void)ZJ_maskImage:(UIImage *)image{
    
    [self ZJ_setImage:image];
    
    //创建一个圆角蒙版
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(self.layer.cornerRadius, self.layer.cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    maskLayer.frame = self.bounds;
    maskLayer.fillColor = [UIColor whiteColor].CGColor;
    
    [self.layer addSublayer:maskLayer];
    self.layer.mask = maskLayer;
}

@end
