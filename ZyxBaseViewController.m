//
//  ZyxBaseViewController.m
//
//  Created by zhouyong on 15/11/23.
//  Copyright © 2015年 zhouyong. All rights reserved.
//

#import "ZyxBaseViewController.h"
#import "MacroDefine.h"
#import "Masonry.h"
#import "UIView+FrameExtension.h"

@interface ZyxBaseViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *presentedView;
@property (nonatomic, strong) UIButton *presentedBackgroundButton;
@property (nonatomic, assign) UIViewLayoutType layout;
@property (nonatomic, weak  ) UIControl *focusedView;

@end

@implementation ZyxBaseViewController

// 同时有Getter和Setter，就需要@synthesize
@synthesize titleContentView = _titleContentView;
@synthesize titleLabel = _titleLabel;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (void)_init {
    _titleViewHeight = kBaseViewControllerTitleViewHeight;
    
    _leftBarButtonWidth = kTitleContentViewHeight;
    _leftBarButtonHeight = kTitleContentViewHeight;
    _leftBarButtonSize = CGSizeE(kTitleContentViewHeight);
    _leftBarButtonLeadingOffset = CGPointZero;
    
    _rightBarButtonWidth = kTitleContentViewHeight;
    _rightBarButtonHeight = kTitleContentViewHeight;
    _rightBarButtonSize = CGSizeE(kTitleContentViewHeight);
    _rightBarButtonTrailingOffset = CGPointZero;
    _isKeyboardObserver = NO;
    _editable = NO;
    _isAllSelected = NO;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    if (kIOS7OrLater) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self addTitleView];
    [self addObserver];
    [self addGestureRecognizers];
    
    self.barButtonVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self backgroundButtonPressed];
}

#pragma mark - Dealloc

- (void)dealloc {
    [self removeObserver];
}

#pragma mark - Override Methods

- (void)backgroundButtonPressed {
    if (_focusedView != nil) {
        [self hideKeyboard];
    } else if (_presentedView.superview != nil) {
        [self dismissPresentedView];
    }
}

// 长按返回root view
- (void)longPressOnLeftBarButton:(UILongPressGestureRecognizer *)gesture {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Add Subviews

- (void)addTitleView {
    [self.view addSubview:self.titleView];
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.mas_equalTo(self.titleViewHeight);
    }];
}

- (void)addObserver {
    [self removeObserver];
    [kNotificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(inputableViewFocused:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(inputableViewFocused:) name:UITextViewTextDidBeginEditingNotification object:nil];
}

- (void)removeObserver {
    [kNotificationCenter removeObserver:self];
}

- (void)addGestureRecognizers {
    // 返回按钮长按事件
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnLeftBarButton:)];
    gesture.delegate = self;
    [self.leftBarButton addGestureRecognizer:gesture];
}

#pragma mark - Button Click Methods

- (void)leftBarButtonPressed:(UIButton *)button {
    if (self.navigationController != nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)rightBarButtonPressed: (UIButton *)button {
}

- (void)cancelEditButtonPressed:(UIButton *)button {
    self.editable = NO;
}

- (void)selectAllButtonPressed:(UIButton *)button {
    self.isAllSelected = YES;
    self.title = [NSString stringWithFormat:@"已选择%@项", @([self numberOfSelectedItems])];
    [self createRightBarButtonWithTitle:@"取消全选" action:@"deselectAllButtonPressed:"];
}

- (void)deselectAllButtonPressed:(UIButton *)button {
    self.isAllSelected = NO;
    self.title = [NSString stringWithFormat:@"已选择%@项", @"0"];
    [self createRightBarButtonWithTitle:@"全选" action:@"selectAllButtonPressed:"];
}

- (NSInteger)numberOfSelectedItems {
    return 0;
}

#pragma mark - Notification Handler

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect beginFrame, endFrame;
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&beginFrame];
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];
    BOOL isHidden = endFrame.origin.y == kWindowHeight;
    if (isHidden) {
        self.focusedView = nil;
    }
    
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    duration = MAX(duration, 0.25f);
    UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration delay:0 options:(curve << 16) animations:^{
        [self keyboardWillChangeFrameFrom:beginFrame to:endFrame isHidden:isHidden];
    } completion:nil];
}

- (void)keyboardWillChangeFrameFrom:(CGRect)beginFrame to:(CGRect)endFrame isHidden:(BOOL)isHidden {
    CGRect frame = [kKeyWindow convertRect:_focusedView.frame fromView:_focusedView.superview];
    CGFloat inputViewY = CGRectGetMaxY(frame);
    CGFloat keyboardY = endFrame.origin.y;
    if (keyboardY >= inputViewY && !isHidden) {
        return;
    }
    
    frame = self.view.frame;
    if (!isHidden) {
        frame.origin.y += keyboardY - inputViewY - 1;
    } else {
        frame.origin = CGPointZero;
    }
    self.view.frame = frame;
}

- (void)inputableViewFocused:(NSNotification *)notification {
    _focusedView = (UIControl *)notification.object;
}

#pragma mark - Util Methods

- (void)removeAllActionsInBarButton:(UIButton *)button {
    NSArray *actions = [button actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    for (NSString *action in actions) {
        RemoveButtonEvent(button, action);
    }
}

- (void)resetLeftBarButtonImageSettings {
    [self.leftBarButton setImage:nil forState:UIControlStateNormal];
    [self.leftBarButton setImage:nil forState:UIControlStateHighlighted];
    [self.leftBarButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.leftBarButton setBackgroundImage:nil forState:UIControlStateHighlighted];
}

- (void)makeButtonAsLeftBarButton:(UIButton *)button {
    [button setImage:UIImageNamed(@"icon_arrow_left") forState:UIControlStateNormal];
    [button setImage:UIImageNamed(@"icon_arrow_left_pressed") forState:UIControlStateHighlighted];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setTitle:@"" forState:UIControlStateHighlighted];
    [self removeAllActionsInBarButton:button];
    AddButtonEvent(button, @"leftBarButtonPressed:");
}

- (void)createNavigationBarButtonWithTitle:(NSString *)title
                                 imageName:(NSString *)imageName
                                    action:(NSString *)action
                                    isLeft:(BOOL)isLeft {
    if (title.length > 0) {
        if (isLeft) {
            self.leftBarButtonTitle = title;
        } else {
            self.rightBarButtonTitle = title;
        }
    }
    
    UIButton *button = isLeft ? self.leftBarButton : self.rightBarButton;
    if (imageName.length > 0) {
        UIImage *image = [UIImage imageNamed:imageName];
        [button setImage:image forState:UIControlStateNormal];
        NSString *pressedImageName = [NSString stringWithFormat:@"%@_pressed", imageName];
        [button setImage:UIImageNamed(pressedImageName) forState:UIControlStateHighlighted];
    }

    [self removeAllActionsInBarButton:button];
    if (action.length > 0) {
         AddButtonEvent(button, action);
    }
}

- (void)createLeftBarButtonWithTitle:(NSString *)title {
    [self createNavigationBarButtonWithTitle:title imageName:@"" action:@"leftBarButtonPressed:" isLeft:YES];
    self.leftBarButtonTitle = title;
}

- (void)createLeftBarButtonWithTitle:(NSString *)title action:(NSString *)action {
    [self createNavigationBarButtonWithTitle:title imageName:@"" action:action isLeft:YES];
    self.leftBarButtonTitle = title;
}

- (void)createLeftBarButtonWithImageName:(NSString *)imageName {
    [self createNavigationBarButtonWithTitle:@"" imageName:imageName action:@"leftBarButtonPressed:" isLeft:YES];
}

- (void)createLeftBarButtonWithImageName:(NSString *)imageName action:(NSString *)action {
    [self createNavigationBarButtonWithTitle:@"" imageName:imageName action:action isLeft:YES];
}

- (void)createRightBarButtonWithTitle:(NSString *)title action:(NSString *)action {
    [self createNavigationBarButtonWithTitle:title imageName:@"" action:action isLeft:NO];
    self.rightBarButtonTitle = title;
}

- (void)createRightBarButtonWithImageName:(NSString *)imageName action:(NSString *)action {
    [self createNavigationBarButtonWithTitle:@"" imageName:imageName action:action isLeft:NO];
}


- (UIButton *)createNavigationBarButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:kNavigationBarFontSize];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.backgroundColor = [UIColor clearColor];
    return button;
}

- (CGFloat)calcTitleWidth {
    NSDictionary *dict = @{NSFontAttributeName:self.titleLabel.font};
    CGFloat width = [self.title sizeWithAttributes:dict].width;
    width = floorf(width) + 4;
    return width;
}

- (void)hideKeyboard {
    if (_focusedView != nil && [_focusedView isFirstResponder]) {
        [_focusedView resignFirstResponder];
    }
}

#pragma mark - Getter and Setter

- (void)setIsKeyboardObserver:(BOOL)isKeyboardObserver {
    if (_isKeyboardObserver == isKeyboardObserver) {
        return;
    }
    
    _isKeyboardObserver = isKeyboardObserver;
    if (isKeyboardObserver) {
        [self addObserver];
    } else {
        [self removeObserver];
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    // 如果只是设置title，没有设置过_titleContentSubview，就直接改text就可以了
    if (_titleContentSubview != _titleLabel) {
        [_titleContentSubview removeFromSuperview];
        _titleContentSubview = nil;
    }
    
    self.titleLabel.text = title;
    if (_titleLabel.superview == nil) {
        [self.titleContentView addSubview:self.titleLabel];
        _titleContentSubview = _titleLabel;
    }
    
    [self makeTitleLabelConstraintsWithWidth:[self calcTitleWidth]];
    [self.titleContentView layoutIfNeeded];
}

- (void)setTitleViewHidden:(BOOL)isTitleViewHidden {
    _isTitleViewHidden = isTitleViewHidden;
    
    NSInteger height = isTitleViewHidden ? 0 : kBaseViewControllerTitleViewHeight;
    if (self.titleViewHeight != height) {
        _titleViewHeight = height;
        
        [self.titleView removeFromSuperview];
        self.titleView = nil;
        [self addTitleView];
        [self.view layoutIfNeeded];
    }
}

- (UIView *)titleView {
    ReturnObjectIfNotNil(_titleView);
    
    UIView *view = [[UIView alloc] init];
    view.mas_key = @"BaseVC.titleView";
    view.backgroundColor = kNavigationBarColor;
    _titleView = view;
    
    if (!_isTitleViewHidden) {
        UIView *subview = [[UIView alloc] init];
        subview.mas_key = @"BaseVC.titleSubview";
        [view addSubview:subview];
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view).insets(UIEdgeInsets(kStatusBarHeight, 0, 0, 0));
        }];
        _titleSubview = subview;
        
        [subview addSubview:self.leftBarButton];
        [subview addSubview:self.rightBarButton];
        
        [subview addSubview:self.titleContentView];
        [_titleContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.leftBarButton.mas_trailing);
            make.trailing.equalTo(self.rightBarButton.mas_leading).offset(_rightBarButtonTrailingOffset.x);
            make.top.equalTo(subview);
            make.bottom.equalTo(subview);
        }];
    }
    
    return view;
}

- (UIView *)titleContentView {
    ReturnObjectIfNotNil(_titleContentView);
    
    UIView *view = [[UIView alloc] init];
    view.mas_key = @"BaseVC.titleContentView";
    _titleContentView = view;
    return view;
}

- (void)setTitleContentView:(UIView *)contentView {
    [_titleContentView removeFromSuperview];
    _titleContentView = nil;
    
    if (contentView == nil) {
        [self.titleView layoutIfNeeded];
        return;
    }
    
    CGFloat contentViewHeight = (contentView.bounds.size.height != 0 ? contentView.bounds.size.height : kTitleContentViewHeight);
    _titleContentView = contentView;
    [self.titleSubview addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.leftBarButton.mas_trailing);
        make.trailing.equalTo(self.rightBarButton.mas_leading);
        make.top.equalTo(self.titleSubview);
        make.height.mas_equalTo(contentViewHeight);
    }];
    
    // 更新titleView的高度，并且刷新界面
    _titleViewHeight = contentViewHeight + kStatusBarHeight;
    [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_titleViewHeight);
    }];
    [self.titleView layoutIfNeeded];
}

- (void)setTitleContentSubview:(UIView *)subview {
    [_titleLabel removeFromSuperview];
    _titleLabel = nil;
    [_titleContentSubview removeFromSuperview];
    _titleContentSubview = nil;
    
    if (subview == nil) {
        [self.titleView layoutIfNeeded];
        return;
    }
    
    CGFloat headerViewHeight = (subview.bounds.size.height != 0 ? subview.bounds.size.height : kTitleContentViewHeight);
    _titleContentSubview = subview;
    [self.titleContentView addSubview:subview];
    [subview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_titleContentView);
    }];
    
    // 更新titleView的高度，并且刷新界面
    _titleViewHeight = headerViewHeight + kStatusBarHeight;
    [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_titleViewHeight);
    }];
    [self.titleView layoutIfNeeded];
}

- (UILabel *)titleLabel {
    ReturnObjectIfNotNil(_titleLabel);
    
    UILabel *label = [[UILabel alloc] init];
    label.text = self.title;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:kNavigationBarFontSize];
    _titleLabel = label;
    label.mas_key = @"BaseVC.titleLabel";
    
    return label;
}

- (void)setTitleLabel:(UILabel *)label {
    [self.titleLabel removeFromSuperview];
    self.titleLabel = nil;
    
    if (label == nil) {
        return;
    }
    _titleLabel = label;
    
    [self.titleContentView addSubview:label];
    [self makeTitleLabelConstraintsWithWidth:label.frame.size.width];
}

- (void)makeTitleLabelConstraintsWithWidth:(CGFloat)width {
    CGFloat deltaX = self.rightBarButtonWidth - self.leftBarButtonWidth;
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.titleContentView).offset(deltaX / 2.0);
        make.top.equalTo(self.titleContentView);
        make.width.equalTo(@(width));
        make.height.equalTo(@(kTitleContentViewHeight));
    }];
}

- (UIButton *)leftBarButton {
    ReturnObjectIfNotNil(_leftBarButton);
    
    UIButton *button = [self createNavigationBarButton];
    button.mas_key = @"BaseVC.leftBarButton";
    [self makeButtonAsLeftBarButton:button];
    AddButtonEvent(button, @"leftBarButtonPressed:");
    _leftBarButton = button;
    return button;
}

- (UIButton *)rightBarButton {
    ReturnObjectIfNotNil(_rightBarButton);
    
    UIButton *button = [self createNavigationBarButton];
    button.mas_key = @"BaseVC.rightBarButton";
    AddButtonEvent(button, @"rightBarButtonPressed:");
    _rightBarButton = button;
    return _rightBarButton;
}

- (void)setLeftBarButtonWidth:(CGFloat)width {
    _leftBarButtonWidth = width;
    _leftBarButtonSize.width = width;
    [self updateBarButton:_leftBarButton size:_leftBarButtonSize];
}

- (void)setLeftBarButtonHeight:(CGFloat)height {
    _leftBarButtonHeight = height;
    _leftBarButtonSize.height = height;
    [self updateBarButton:_leftBarButton size:_leftBarButtonSize];
}

- (void)setLeftBarButtonSize:(CGSize)size {
    _leftBarButtonWidth = size.width;
    _leftBarButtonHeight = size.height;
    _leftBarButtonSize = size;
    [self updateBarButton:_leftBarButton size:_leftBarButtonSize];
}

- (void)setLeftBarButtonLeadingOffset:(CGPoint)offset {
    _leftBarButtonLeadingOffset = offset;
    [self updateBarButton:_leftBarButton offset:offset isLeftBarButton:YES];
}

- (void)setRightBarButtonWidth:(CGFloat)width {
    _rightBarButtonWidth = width;
    _rightBarButtonSize.width = width;
    [self updateBarButton:_rightBarButton size:_rightBarButtonSize];
}

- (void)setRightBarButtonHeight:(CGFloat)height {
    _rightBarButtonHeight = height;
    _rightBarButtonSize.height = height;
    [self updateBarButton:_rightBarButton size:_rightBarButtonSize];
}

- (void)setRightBarButtonSize:(CGSize)size {
    _rightBarButtonWidth = size.width;
    _rightBarButtonHeight = size.height;
    _rightBarButtonSize = size;
    [self updateBarButton:_rightBarButton size:_rightBarButtonSize];
}

- (void)setRightBarButtonTrailingOffset:(CGPoint)offset {
    _rightBarButtonTrailingOffset = offset;
    [self updateBarButton:_rightBarButton offset:offset isLeftBarButton:NO];
}

- (void)setLeftBarButtonTitle:(NSString *)title {
    _leftBarButtonTitle = title;
    
    [self.leftBarButton setTitle:title forState:UIControlStateNormal];
    [self resetLeftBarButtonImageSettings];
    // 更新按钮宽度
    CGFloat width = roundf([title sizeWithAttributes:@{NSFontAttributeName: self.leftBarButton.titleLabel.font}].width) + 14;
    self.leftBarButtonWidth = width;
}

- (void)setRightBarButtonTitle:(NSString *)title {
    _rightBarButtonTitle = title;
    
    [self.rightBarButton setTitle:title forState:UIControlStateNormal];
    // 更新按钮宽度
    CGFloat width = roundf([title sizeWithAttributes:@{NSFontAttributeName: self.rightBarButton.titleLabel.font}].width) + 14;
    self.rightBarButtonWidth = width;
}

// 更新button的相对位置
- (void)setBarButtonVerticalAlignment:(UIControlContentVerticalAlignment)alignment {
    _barButtonVerticalAlignment = alignment;
    
    // 如果是上对齐或者下对齐，就根据offset重新调整button的位置
    if (alignment == UIControlContentVerticalAlignmentTop || alignment == UIControlContentVerticalAlignmentBottom) {
        [self updateBarButton:_leftBarButton offset:_leftBarButtonLeadingOffset isLeftBarButton:YES];
        [self updateBarButton:_rightBarButton offset:_rightBarButtonTrailingOffset isLeftBarButton:NO];
    }
    // 如果是居中对齐，offset.y失效，offset.x依旧有效，重新调整button的位置
    else if (alignment == UIControlContentVerticalAlignmentCenter) {
        [_leftBarButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_titleSubview).offset(_leftBarButtonLeadingOffset.x);
            make.centerY.equalTo(_titleSubview);
            make.size.mas_equalTo(_leftBarButtonSize);
        }];
        [_rightBarButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_titleSubview).offset(_rightBarButtonTrailingOffset.x);
            make.centerY.equalTo(_titleSubview);
            make.size.mas_equalTo(_rightBarButtonSize);
        }];
    }
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    
    if (self.isTitleViewHidden) {
        return;
    }
    
    static BOOL saved = NO;
    static NSString *title = nil, *rightBarButtonTitle = nil, *rightBarButtonAction = nil;
    if (!saved) {
        saved = YES;
        title = self.title;
        rightBarButtonTitle = self.rightBarButtonTitle;
        rightBarButtonAction = [self.rightBarButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside].firstObject;
    }
    
    if (editable) {
        self.title = [NSString stringWithFormat:@"已选择%@项", @"0"];
        [self createLeftBarButtonWithTitle:@"取消" action:@"cancelEditButtonPressed:"];
        [self createRightBarButtonWithTitle:@"全选" action:@"selectAllButtonPressed:"];
    } else {
        self.title = title;
        [self makeButtonAsLeftBarButton:self.leftBarButton];
        self.leftBarButtonWidth = 44;
        [self createRightBarButtonWithTitle:rightBarButtonTitle action:rightBarButtonAction];
    }
}

#pragma mark - Util Methods

- (void)updateBarButton:(UIButton *)button size:(CGSize)size {
    [button mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
    CGFloat deltaX = self.rightBarButtonWidth - self.leftBarButtonWidth;
    [self.titleContentSubview mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.titleContentView).offset(deltaX / 2.0);
    }];
    [self.titleSubview layoutIfNeeded];
}

// 更新button的偏移量，居中对齐时，偏移量失效；上对齐时，offset对应左上角，下对齐时，offset对应右下角
- (void)updateBarButton:(UIButton *)button offset:(CGPoint)pt isLeftBarButton:(BOOL)isLeftBarButton {    
    BOOL isTopAlignment = _barButtonVerticalAlignment == UIControlContentVerticalAlignmentTop;
    CGSize size = isLeftBarButton ? _leftBarButtonSize : _rightBarButtonSize;
    [button mas_remakeConstraints:^(MASConstraintMaker *make) {
        MASConstraint *horConstraint = isLeftBarButton ? make.leading : make.trailing;
        MASConstraint *verConstraint = isTopAlignment ? make.top : make.bottom;
        horConstraint.equalTo(_titleSubview).offset(pt.x);
        verConstraint.equalTo(_titleSubview).offset(pt.y);
        make.size.mas_equalTo(size);
    }];
    [self.titleView layoutIfNeeded];
}

- (void)presentOrHideView:(UIView *)view layout:(UIViewLayoutType)layout {
    if (_presentedView != nil) {
        [self dismissPresentedView];
    } else {
        [self presentView:view layout:layout];
    }
}

- (void)presentView:(UIView *)view layout:(UIViewLayoutType)layout {
    if (_presentedView != nil) {
        [self dismissPresentedViewWithCompletion:^{
            [self showView:view layout:layout];
        }];
    } else {
        [self showView:view layout:layout];
    }
}

- (void)showView:(UIView *)view layout:(UIViewLayoutType)layout {
    CGFloat viewWidth = view.bounds.size.width;
    CGFloat viewHeight = view.bounds.size.height;
    if (viewWidth == 0) {
        viewWidth = kWindowWidth;
    }

    UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backgroundButton.frame = self.view.bounds;
    backgroundButton.backgroundColor = [UIColor blackColor];
    backgroundButton.alpha = 0.6f;
    AddButtonEvent(backgroundButton, @"backgroundButtonPressed");
    
    // 为了让titleview不被遮挡
    if ((layout & UIViewLayoutTypeTop) && !_isTitleViewHidden) {
        [self.view bringSubviewToFront:_titleView];
        [self.view insertSubview:backgroundButton belowSubview:self.titleView];
    } else {
        [self.view addSubview:backgroundButton];
    }
    
    NSArray<NSValue *> *points = [self pointsWithPresentView:view andLayoutType:layout];
    CGPoint startPoint = [points.firstObject CGPointValue];
    CGPoint endPoint = [points.lastObject CGPointValue];
    view.frame = CGRect(startPoint.x, startPoint.y, viewWidth, viewHeight);
    view.alpha = 0;
    [self.view insertSubview:view aboveSubview:backgroundButton];
    
    [UIView animateWithDuration:0.3f animations:^{
        view.frame = CGRect(endPoint.x, endPoint.y, viewWidth, viewHeight);
        view.alpha = 1;
    }];
    
    self.presentedBackgroundButton = backgroundButton;
    self.presentedView = view;
    self.layout = layout;
    
    view.layer.cornerRadius = 5;
    view.clipsToBounds = NO;
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(-3, 3);
    view.layer.shadowOpacity = 0.8;
}

- (void)dismissPresentedViewWithCompletion:(void (^)())completion {
    if (_presentedView == nil) {
        completion();
        return;
    }
    
    NSArray<NSValue *> *points = [self pointsWithPresentView:_presentedView andLayoutType:_layout];
    CGPoint endPoint = [points.firstObject CGPointValue];
    
    CGRect frame = _presentedView.frame;
    frame.origin = endPoint;
    
    kWeakself;
    [UIView animateWithDuration:.4f animations:^{
        _presentedView.frame = frame;
        _presentedView.alpha = 0;
    } completion:^(BOOL finished) {
        [_presentedView removeFromSuperview];
        [_presentedBackgroundButton removeFromSuperview];
        weakself.presentedView = nil;
        weakself.presentedBackgroundButton = nil;
        weakself.layout = UIViewLayoutTypeNone;
        
        ExecuteBlockIfNotNil(completion);
    }];
}

- (void)dismissPresentedView {
    [self dismissPresentedViewWithCompletion:nil];
}

- (NSArray<NSValue *> *)pointsWithPresentView:(UIView *)view andLayoutType:(UIViewLayoutType)layout {
    CGFloat viewWidth = view.bounds.size.width;
    CGFloat viewHeight = view.bounds.size.height;
    if (viewWidth == 0) {
        viewWidth = kWindowWidth;
    }
    
    CGFloat centerX = (self.view.bounds.size.width - viewWidth) / 2.f;
    CGFloat centerY = (self.view.bounds.size.height - viewHeight) / 2.f;
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    switch (layout) {
        case UIViewLayoutTypeTopLeft:
            startPoint = CGPoint(self.view.x - viewWidth, self.titleView.bottomY);
            endPoint   = CGPoint(self.view.x, self.view.y);
            break;
        case UIViewLayoutTypeTopCenter:
            startPoint = CGPoint(centerX, self.view.y - viewHeight);
            endPoint   = CGPoint(centerX, self.titleView.bottomY);
            break;
        case UIViewLayoutTypeTopRight:
            startPoint = CGPoint(self.view.rightX, self.titleView.bottomY);
            endPoint   = CGPoint(self.view.rightX - viewWidth, self.titleView.bottomY);
            break;
        case UIViewLayoutTypeCenterLeft:
            startPoint = CGPoint(self.view.x - viewWidth, centerY);
            endPoint = CGPoint(self.view.x, centerY);
            break;
        case UIViewLayoutTypeCenter:
            startPoint = CGPoint(centerX, self.view.y - viewHeight);
            endPoint   = CGPoint(centerX, centerY);
            break;
        case UIViewLayoutTypeCenterRight:
            startPoint = CGPoint(self.view.rightX, centerY);
            endPoint   = CGPoint(self.view.rightX - viewWidth, centerY);
            break;
        case UIViewLayoutTypeBottomLeft:
            startPoint = CGPoint(self.view.x - viewWidth, self.view.bottomY - viewHeight);
            endPoint   = CGPoint(self.view.x - viewWidth, self.view.bottomY);
            break;
        case UIViewLayoutTypeBottomCenter:
            startPoint = CGPoint(centerX, self.view.bottomY);
            endPoint   = CGPoint(centerX, self.view.bottomY - viewHeight);
            break;
        case UIViewLayoutTypeBottomRight:
            startPoint = CGPoint(self.view.rightX, self.view.bottomY);
            endPoint   = CGPoint(self.view.rightX - viewWidth, self.view.bottomY - viewHeight);
            break;
        default:
            break;
    }
    return @[[NSValue valueWithCGPoint:startPoint], [NSValue valueWithCGPoint:endPoint]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
