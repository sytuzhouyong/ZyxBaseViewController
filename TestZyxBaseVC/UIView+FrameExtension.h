//
//  UIView+FrameExtension.m
//
//  Created by zhouyong on 14-11-14.
//  Copyright (c) 2014年 zhouyong. All rights reserved.
//


#import <UIKit/UIKit.h>

#define SHOW_BORDER(__v, __r) __v.layer.borderColor = [UIColor __r].CGColor; __v.layer.borderWidth = 1

@interface UIView (FrameExtension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat rightX;
@property (nonatomic, assign) CGFloat bottomY;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGPoint topLeft;
@property (nonatomic, assign) CGPoint topRight;
@property (nonatomic, assign) CGPoint bottomLeft;
@property (nonatomic, assign) CGPoint bottomRight;

- (void)setAnchorPoint:(CGPoint)anchorPoint;

@end
