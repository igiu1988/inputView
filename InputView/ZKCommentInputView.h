//
//  ZKCommentInputView.h
//  yingshibaokaoyan
//
//  Created by wangyang on 7/16/14.
//  Copyright (c) 2014 com.zkyj.yingshibao.kaoyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

/**
 *  当结束输入（录音）时会调用。
 *
 *  @param inputView        ZKCommentInputView自己
 *  @param text             用户输入的文字，如果没有输入文字，参数为@""
 *  @param data             用户录制的语音，如果没有录制语音，参数为nil
 *  @param duration         音频的时长，如果没有录制，参数为@0
 *  @param success          YES表示将要发送，NO表示中途取消。
 */
typedef void(^InputViewDidFinishInput)(id inputView,  NSString *text, NSData *data, NSNumber *duration, BOOL success);

@interface ZKCommentInputView : UIView
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) InputViewDidFinishInput finishBlock;

- (void)showTextInput;
- (void)showRecordView;

/**
 *  主动取消输入，会调用finishBlock
 */
- (void)dismissKeyboard;
@end
