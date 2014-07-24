//
//  ZKCommentInputView.m
//  yingshibaokaoyan
//
//  Created by wangyang on 7/16/14.
//  Copyright (c) 2014 com.zkyj.yingshibao.kaoyao. All rights reserved.
//

#import "ZKCommentInputView.h"
#import "UIView+Utils.h"
#import "WYRecorder.h"
#import "amrFileCodec.h"

#define UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] applicationFrame].size.width)
#define UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] applicationFrame].size.height)

@interface ZKCommentInputView () <HPGrowingTextViewDelegate>
{
    WYRecorder *recorder;
    
    UIView *inputBox;
    
    UILabel *recordLabel;
    UIButton *recordButton;
    UIButton *switchButton;
    
    // 录音相关的view
    UIView *recordAssistentView;
    UILabel *trialLabel;    // 试听
    UILabel *trashLabel;    // 放弃
    
    
}
@property (nonatomic, strong) NSData *amrData;
@end

@implementation ZKCommentInputView

#pragma mark - Life Cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    self.bottom = newSuperview.bottom;
}

- (void)setup
{
    [self setupRecorder];
    [self setupView];
}

- (void)setupRecorder
{
    __weak ZKCommentInputView *weakSelf = self;
    
    recorder = [WYRecorder new];
    recorder.recordFinish = ^(BOOL success, NSData *data){
        // 转码为amr
        weakSelf.amrData = EncodeWAVEToAMR(data,1,16);
    };
    recorder.periodicTimeBlock = ^(double currentPower, AVAudioRecorder *recorder){
        NSLog(@"电平水平：%f", currentPower);
    };
}

- (void)setupView
{
    // View
    self.frame = [UIScreen mainScreen].bounds;
    [self setupInputBox];
    [self setupRecordAssistentView];
}

- (void)setupInputBox
{
    inputBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    inputBox.bottom = self.bottom;
    inputBox.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    inputBox.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:inputBox];
    // 这个事个inputView的背景
    //    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    //    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    //    imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    //    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //    [inputBox addSubview:imageView];
	
	_textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(45, 0, 240, 40)];
    _textView.isScrollable = NO;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	_textView.minNumberOfLines = 1;
	_textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // _textView.maxHeight = 200.0f;
	_textView.returnKeyType = UIReturnKeyGo; //just as an example
	_textView.font = [UIFont systemFontOfSize:15.0f];
	_textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.placeholder = @"Type to see the _textView grow!";
    [inputBox addSubview:_textView];
    // _textView.text = @"test\n\ntest";
	// _textView.animateHeightChange = NO; //turns off animation
    
    
    // 把这下面的Image view盖在text view上
    //    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    //    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    //    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    //    entryImageView.frame = CGRectMake(45, 0, 240, 40);
    //    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //    [self addSubview:entryImageView];
    
    
    // 发送button
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(_textView.right + 5, 8, 40, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"发送" forState:UIControlStateNormal];
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(textViewSendAction) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[inputBox addSubview:doneBtn];
    
    
    // 切换音频及文字输入
    switchButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 3, 50, 35)];
    [switchButton setTitle:@"切换" forState:UIControlStateNormal];
    [switchButton addTarget:self action:@selector(inputSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [inputBox addSubview:switchButton];
    
    
    // 下面是音频输入的UI，是隐藏的
    recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 3, 200, 40)];
    recordLabel.backgroundColor = [UIColor greenColor];
    recordLabel.textAlignment = NSTextAlignmentCenter;
    [inputBox addSubview:recordLabel];
    recordLabel.hidden = YES;
    recordLabel.text = @"按住说话";
    
}

- (void)setupRecordAssistentView
{
    CGPoint center = CGPointMake(UI_SCREEN_WIDTH/2, fabsf(self.top) + (self.bottom - fabsf(self.top))/2);
    
    recordAssistentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 110)];
    recordAssistentView.backgroundColor = [UIColor clearColor];
    recordAssistentView.center = center;
    recordAssistentView.hidden = YES;
    
    trialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 110)];
    trialLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.458 blue:0.221 alpha:0.560];
    trialLabel.text = @"移到这儿试听";
    trialLabel.userInteractionEnabled = YES;
    
    trashLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 110, 110)];
    trashLabel.backgroundColor = [UIColor colorWithRed:0.464 green:0.688 blue:1.000 alpha:0.560];;
    trashLabel.text = @"移到这儿放弃";
    trashLabel.userInteractionEnabled = YES;
    
    [recordAssistentView addSubview:trialLabel];
    [recordAssistentView addSubview:trashLabel];
    [self addSubview:recordAssistentView];
}

- (void)setupRecordStatusView
{
    
}

#pragma mark - 切换文字输入或者语音输入
- (void)inputSwitch:(UIButton *)button
{
    if (button.selected) {
        [self showTextInput];
    }else{
        [self showRecordView];
    }
}

- (void)showTextInput
{
    switchButton.selected = NO;
    _textView.hidden = NO;
    recordLabel.hidden = YES;
    recordAssistentView.hidden = YES;
    [_textView becomeFirstResponder];
    
}

- (void)showRecordView
{
    switchButton.selected = YES;
    _textView.hidden = YES;
    recordLabel.hidden = NO;
    [_textView resignFirstResponder];
    self.bottom = self.window.bottom;
}



#pragma mark - 取消输入
- (void)dismissKeyboard
{
    [_textView resignFirstResponder];
    [self removeFromSuperview];
}

#pragma mark - 发送消息
- (void)textViewSendAction
{
    if (_finishBlock) {
        _finishBlock(self, _textView.text, nil, @0, YES);
    }
    
    [self dismissKeyboard];
}

- (void)audioSendActionWithAudio:(NSData *)audioData duration:(NSNumber *)duration
{
    if (_finishBlock) {
        _finishBlock(self, @"", audioData, duration, YES);
    }
}


#pragma mark - 播放声音

- (void)PlayVoice:(id)sender {
    
}


#pragma mark - 录音 -- 手势相关
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"begin");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:inputBox];
    if (CGRectContainsPoint(recordLabel.frame, point)) {
        recordLabel.text = @"松开发送";
        recordAssistentView.hidden = NO;
        [recorder startRecord];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"move");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:recordAssistentView];
    
    NSLog(@"%@", NSStringFromCGPoint(point));
    if (point.y > 110.0 && point.y < 180) {
        // TODO: 触发recored assistent view
        recordAssistentView.hidden = NO;
    }else if (CGRectContainsPoint(trialLabel.frame, point)) {
        trialLabel.text = @"放开手指开始试听";
    }else if (CGRectContainsPoint(trashLabel.frame, point)) {
        trashLabel.text = @"放开手指以放弃";
    }else{
        trialLabel.text = @"移到这儿试听";
        trashLabel.text = @"移到这儿放弃";
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"end");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:recordAssistentView];
    
    if (CGRectContainsPoint(trialLabel.frame, point)) {
        // TODO: 开始试听
        recordAssistentView.hidden = YES;
    }else if (CGRectContainsPoint(trashLabel.frame, point)) {
        // TODO: 放弃
        [self restoreRecordView];
    }else{
        // TODO: 发出
        NSLog(@"发出信息");
        [self restoreRecordView];
    }
}

- (void)restoreRecordView
{
    recordLabel.text = @"按住说话";
    recordAssistentView.hidden = YES;
}

#pragma mark - HPGrowingTextView Delegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.frame = r;
}
@end
