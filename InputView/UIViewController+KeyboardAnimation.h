//
//  UIViewController+KeyboardAnimation.h
//  yingshibaokaoyan
//
//  Created by wangyang on 7/17/14.
//  Copyright (c) 2014 com.zkyj.yingshibao.kaoyao. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  使用该类别，以方便的控制键盘事件及对应textView，view的位置处理
 */
@interface UIViewController (KeyboardAnimation)

// 输入视图，可能是一个text view、textField，或者是一个自定义的view
@property (nonatomic, strong) UIView *inputView;

// 在键盘弹出及收回时，需要移动的view，可能是inputView本身，也可能是inputView.superView，或者其它
@property (nonatomic, strong) UIView *targeMoveView;
- (void)observeKeyboard;
- (void)removeObservKeyboard;
@end
