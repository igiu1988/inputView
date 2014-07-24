//
//  UIViewController+KeyboardAnimation.m
//  yingshibaokaoyan
//
//  Created by wangyang on 7/17/14.
//  Copyright (c) 2014 com.zkyj.yingshibao.kaoyao. All rights reserved.
//

#import "UIViewController+KeyboardAnimation.h"
#import <objc/runtime.h>

static const char kInputView;
static const char kTargeMoveView;
@implementation UIViewController (KeyboardAnimation)
@dynamic inputView;
@dynamic targeMoveView;


#pragma mark - 属性get、set

- (UIView *)inputView
{
    return objc_getAssociatedObject(self, &kInputView);
}

- (void)setInputView:(UIView *)inputView
{
    objc_setAssociatedObject(self, &kInputView, inputView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)targeMoveView
{
    return objc_getAssociatedObject(self, &kTargeMoveView);
}

- (void)setTargeMoveView:(UIView *)targeMoveView
{
    objc_setAssociatedObject(self, &kTargeMoveView, targeMoveView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - 监听

- (void)observeKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeObservKeyboard
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - 监听响应


- (void)keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardFrame;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardFrame];
    // Need to translate the bounds to account for rotation.
    UIView *view = self.inputView.superview;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        NSAssert(0, @"window 是nil，向我报一个bug吧");
    }
    keyboardFrame = [window convertRect:keyboardFrame toView:view];
    
    // 用keyboard的y坐标减去inputView的底部坐标，得到offset
    CGFloat offset = keyboardFrame.origin.y - (self.inputView.frame.size.height + self.inputView.frame.origin.y);
    
    // offset >= 0 ，说明inputView完全在键盘上面，不需要移动
    if (offset >= 0 ) {
        return;
    }

    
	NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
    self.targeMoveView.transform = CGAffineTransformMakeTranslation(0, offset);
	
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];

	self.targeMoveView.transform = CGAffineTransformIdentity;

	[UIView commitAnimations];
}
@end
