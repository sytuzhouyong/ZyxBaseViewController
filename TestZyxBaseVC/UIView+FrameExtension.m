//
//  UIView+FrameExtension.m
//
//  Created by zhouyong on 14-11-14.
//  Copyright (c) 2014年 zhouyong. All rights reserved.
//

#import "UIView+FrameExtension.h"

@implementation UIView (FrameExtension)

- (CGFloat)x {
    return self.frame.origin.x;
}
- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)rightX {
    return self.x + self.width;
}
- (void)setRightX:(CGFloat)rightX {
    self.x = rightX - self.width;
}

- (CGFloat)bottomY {
    return self.y + self.height;
}
- (void)setBottomY:(CGFloat)bottomY {
    self.y = bottomY - self.height;
}

#pragma mark - 

- (CGFloat)width {
    return self.bounds.size.width;
}
- (void)setWidth:(CGFloat)width {
    CGRect bounds = self.bounds;
    bounds.size.width = width;
    self.bounds = bounds;
}

- (CGFloat)height {
    return self.bounds.size.height;
}
- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

#pragma mark - Size

- (CGSize)size {
    return self.bounds.size;
}
- (void)setSize:(CGSize)size {
    CGRect bounds = self.bounds;
    bounds.size = size;
    self.bounds = bounds;
}

#pragma mark - Position

- (CGPoint)topLeft {
    return CGPointMake(self.x, self.y);
}
- (void)setTopLeft:(CGPoint)topLeft {
    CGRect frame = self.frame;
    frame.origin = topLeft;
    self.frame = frame;
}

- (CGPoint)topRight {
    return CGPointMake(self.x + self.width, self.y);
}
- (void)setTopRight:(CGPoint)topRight {
    CGRect frame = self.frame;
    frame.origin.x = topRight.x - self.width;
    frame.origin.y = topRight.y;
    self.frame = frame;
}

- (CGPoint)bottomLeft {
    return CGPointMake(self.x, self.y + self.height);
}
- (void)setBottomLeft:(CGPoint)bottomLeft {
    CGRect frame = self.frame;
    frame.origin.x = bottomLeft.x;
    frame.origin.y = bottomLeft.y - self.height;
    self.frame = frame;
}

- (CGPoint)bottomRight {
    return CGPointMake(self.x + self.width, self.y + self.height);
}
- (void)setBottomRight:(CGPoint)bottomRight {
    CGRect frame = self.frame;
    frame.origin.x = bottomRight.x - self.width;
    frame.origin.y = bottomRight.y - self.height;
    self.frame = frame;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    CGPoint oldOrigin = self.frame.origin;
    self.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = self.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    self.center = CGPointMake(self.center.x - transition.x, self.center.y - transition.y);
}

@end
