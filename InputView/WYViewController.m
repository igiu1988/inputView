//
//  WYViewController.m
//  InputView
//
//  Created by wangyang on 7/21/14.
//  Copyright (c) 2014 com.wy. All rights reserved.
//

#import "WYViewController.h"
#import "ZKCommentInputView.h"
#import "UIViewController+KeyboardAnimation.h"

@interface WYViewController ()
{
    
}
@end

@implementation WYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self observeKeyboard];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self buttonClick];
    });
}

- (IBAction)buttonClick
{

    ZKCommentInputView *inputView = [ZKCommentInputView new];
    inputView.finishBlock = ^(id inputView,  NSString *text, NSData *data, NSNumber *duration, BOOL success){
        if (text.length > 0 ) {
            NSLog(@"发送文本");
        }else{
            NSLog(@"发送音频");
        }
    };
    self.inputView = inputView;
    self.targeMoveView = inputView;
    [self.view addSubview:inputView];
    
    [inputView showRecordView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
