//
//  ZyxBaseViewController.h
//
//
//  Created by zhouyong on 15/11/23.
//  Copyright © 2015年 zte. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIViewLayoutType) {
    UIViewLayoutTypeNone    = 0x0000,
    UIViewLayoutTypeTop     = 0x0001,
    UIViewLayoutTypeBottom  = 0x0002,
    UIViewLayoutTypeLeft    = 0x0010,
    UIViewLayoutTypeRight   = 0x0020,
    UIViewLayoutTypeCenter  = 0x0004,
    
    UIViewLayoutTypeTopLeft         = UIViewLayoutTypeTop | UIViewLayoutTypeLeft,
    UIViewLayoutTypeTopCenter       = UIViewLayoutTypeTop | UIViewLayoutTypeCenter,
    UIViewLayoutTypeTopRight        = UIViewLayoutTypeTop | UIViewLayoutTypeRight,
    
    UIViewLayoutTypeCenterLeft      = UIViewLayoutTypeCenter | UIViewLayoutTypeLeft,
    UIViewLayoutTypeCenterRight     = UIViewLayoutTypeCenter | UIViewLayoutTypeRight,
    
    UIViewLayoutTypeBottomLeft      = UIViewLayoutTypeBottom | UIViewLayoutTypeLeft,
    UIViewLayoutTypeBottomCenter    = UIViewLayoutTypeBottom | UIViewLayoutTypeCenter,
    UIViewLayoutTypeBottomRight     = UIViewLayoutTypeBottom | UIViewLayoutTypeRight,
};

@interface ZyxBaseViewController : UIViewController

@property (nonatomic, assign, setter=setTitleViewHidden:) BOOL isTitleViewHidden;
@property (nonatomic, assign) UIControlContentVerticalAlignment barButtonVerticalAlignment;
@property (nonatomic, assign, readonly) NSInteger titleViewHeight;

@property (nonatomic, assign) BOOL isKeyboardObserver;

@property (nonatomic, assign) CGFloat leftBarButtonWidth;
@property (nonatomic, assign) CGFloat leftBarButtonHeight;
@property (nonatomic, assign) CGSize leftBarButtonSize;
@property (nonatomic, assign) CGPoint leftBarButtonLeadingOffset;
@property (nonatomic, copy  ) NSString *leftBarButtonTitle;

@property (nonatomic, assign) CGFloat rightBarButtonWidth;
@property (nonatomic, assign) CGFloat rightBarButtonHeight;
@property (nonatomic, assign) CGSize rightBarButtonSize;
@property (nonatomic, assign) CGPoint rightBarButtonTrailingOffset;
@property (nonatomic, copy  ) NSString *rightBarButtonTitle;

@property (nonatomic, strong) UIView *titleView;            // 整个标题栏，包括状态栏区域
@property (nonatomic, strong) UIView *titleSubview;         // titleView除去状态栏后的区域
@property (nonatomic, strong) UIView *titleContentView;     // titleSubview除去左右按钮后的区域
@property (nonatomic, strong) UIView *titleContentSubview;  // 自定义的header view，是titleContentView的子view
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftBarButton;
@property (nonatomic, strong) UIButton *rightBarButton;

@property (nonatomic, assign) BOOL editable;    // 编辑模式，实现全选，取消全选等的UI变化，具体数据需要重载函数
@property (nonatomic, assign) BOOL isAllSelected; // 是否全选中

- (void)createLeftBarButtonWithTitle:(NSString *)title;
- (void)createLeftBarButtonWithImageName:(NSString *)imageName;
- (void)createLeftBarButtonWithTitle:(NSString *)title action:(NSString *)action;
- (void)createLeftBarButtonWithImageName:(NSString *)imageName action:(NSString *)action;
- (void)createRightBarButtonWithTitle:(NSString *)title action:(NSString *)action;
- (void)createRightBarButtonWithImageName:(NSString *)imageName action:(NSString *)action;

- (void)leftBarButtonPressed:(UIButton *)button;
- (void)selectAllButtonPressed:(UIButton *)button;
- (void)deselectAllButtonPressed:(UIButton *)button;
- (void)cancelEditButtonPressed:(UIButton *)button;
- (NSInteger)numberOfSelectedItems;

- (void)resetLeftBarButtonImageSettings;
- (void)makeButtonAsLeftBarButton:(UIButton *)button;

- (void)keyboardWillChangeFrameFrom:(CGRect)beginFrame to:(CGRect)endFrame isHidden:(BOOL)isHidden;

// view会被BaseViewController持有，如果view在当前ViewController中也被持有，会导致view在dismiss后内存不会释放，要等到当前ViewController pop掉后才能释放
- (void)presentView:(UIView *)view layout:(UIViewLayoutType)layout;
- (void)dismissPresentedView;

@end
