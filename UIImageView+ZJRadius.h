//
//  UIImageView+ZJRadius.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ZJRadius)

/**
 剪裁之前的图片
 */
@property (nonatomic, strong) UIImage *orginImage;

/**
 是否需要剪裁
 */
@property (nonatomic, assign, getter=isClipsCorner) BOOL clipsCorner;

@end
