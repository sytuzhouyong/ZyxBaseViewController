//
//  Common.m
//  XingHomecloud
//
//  Created by zhouyong on 15/11/23.
//  Copyright © 2015年 zte. All rights reserved.
//

#pragma mark - 常量宏

#define kWindowFrame                        [[UIScreen mainScreen] bounds]
#define kWindwoSize                         kWindowFrame.size
#define kWindowWidth                        kWindwoSize.width
#define kWindowHeight                       kWindwoSize.height
#define kNavigationBarColor                 RGB(0x18, 0x5C, 0xC1)
#define kStatusBarHeight                    20
#define kTitleContentViewHeight             44
#define kBaseViewControllerTitleViewHeight  64
#define kNavigationBarFontSize              15
#define kFileTitleDateFormat                @"yyyy_MM_dd_HH:mm:ss"

#pragma mark - 常用对象宏

#define kApplication            [UIApplication sharedApplication]
#define kAppDelegate            ((AppDelegate *)[kApplication delegate])
#define kKeyWindow              kApplication.keyWindow
#define kNotificationCenter     [NSNotificationCenter defaultCenter]
#define kUserDefaults           [NSUserDefaults standardUserDefaults]

#pragma mark - 简便函数宏

#define RGBA(r,g,b,a)               [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:a]
#define RGB(r,g,b)                  RGBA(r,g,b,1.0)
#define GrayColor(_c)               RGB(_c,_c,_c)
#define GrayColorA(_c, _a)          RGBA(_c,_c,_c,_a)
#define UIImageNamed(_n)            [UIImage imageNamed:_n]
#define UIFontOfSize(_s)            [UIFont systemFontOfSize:_s]
#define CGPoint(_x, _y)             CGPointMake(_x, _y)
#define CGSize(_w, _h)              CGSizeMake(_w, _h)
#define CGSizeE(_s)                 CGSizeMake(_s, _s)
#define CGRect(__x,__y,__w,__h)     CGRectMake(__x, __y, __w, __h)
#define UIEdgeInsets(_t,_l,_b,_r)   UIEdgeInsetsMake(_t, _l, _b, _r)
#define NSIndexPath(section, row)   [NSIndexPath indexPathForRow:row inSection:section]

#define kIOS7OrLater                ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
#define kWeakself                   __weak __typeof(&*self) weakself = self
#define SafeString(_s)              (_s != nil ? _s : @"")
#define ReturnObjectIfNotNil(_o)    if (_o != nil) { return _o; }
#define ReturnIfBlockIsNil(_b)      if (_b == nil) { return; }
#define ReturnIfArrayIsEmpty(_a)    if (_a.count == 0) { return; }

#define ExecuteBlockIfNotNil(_b)                !_b ?: _b()
#define ExecuteBlock1IfNotNil(_b, _v1)          !_b ?: _b(_v1)
#define ExecuteBlock2IfNotNil(_b, _v1, _v2)     !_b ?: _b(_v1, _v2)

#define InfoPlistValueForKey(_k)    [[NSBundle mainBundle] infoDictionary][_k]
#define kAppVersion                 InfoPlistValueForKey(@"CFBundleVersion")

#define AddButtonEvent(_b, _e)  \
    [_b addTarget:self action:NSSelectorFromString(_e) forControlEvents:UIControlEventTouchUpInside]
#define AddButtonEventTarget(_t, _b, _e) \
    [_b addTarget:_t action:NSSelectorFromString(_e) forControlEvents:UIControlEventTouchUpInside]
#define RemoveButtonEvent(_b, _e)\
    [_b removeTarget:self action:NSSelectorFromString(_e) forControlEvents:UIControlEventTouchUpInside]
#define SetButtonImage(_b, _n) \
    [_b setImage:UIImageNamed(_n) forState:UIControlStateNormal]; \
    [_b setImage:UIImageNamed(_n@"_pressed") forState:UIControlStateHighlighted]
#define PresentListView(_view, _class, _titles, _layout) \
    do { \
        if (_view == nil) { \
            _view = [[_class alloc] initWithTitles:_titles cellHeight:50]; \
            _view.delegate = self; \
        } \
        if (_view.superview == nil) { \
            [self presentView:_view layout:_layout]; \
        } else { \
            [self dismissPresentedView]; \
        } \
    } while (NO)


