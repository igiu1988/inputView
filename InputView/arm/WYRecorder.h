//
//  RecordAudio.h
//  JuuJuu
//
//  Created by xiaoguang huang on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "amrFileCodec.h"



/**
 *  amrRecorder
 *  就是录音。现在这个录音只支持一种录音格式: PCM，并且是为人声录音优化的。可以在以后慢慢完善
 */
@interface WYRecorder : NSObject


/**
 *  正在录音时，每0.05秒调用一次。
 *  通过该方法可以取得录音变化的时间，及电平水平
 *
 *  @param currentPower         当前音量的电平表示。取值为0~1
 *  @param recorder             正在使用的录音器
 */
@property (nonatomic, strong) void (^periodicTimeBlock)(double currentPower, AVAudioRecorder *recorder);

/**
 *  录音结束时调用。
 *  如果要将录音转制为iPhone本身不支持的格式。在这里转制就可以
 *  
 *  @param  success     录制成功是：YES；取消时为NO
 *  @param  data        录制成功后返回录制的音频数据。如果success=NO时，请忽略data的值
 */
@property (nonatomic, strong) void (^recordFinish)(BOOL success, NSData *data);

- (void)startRecord;
- (void)stopRecord;
- (void)abortRecord;

@end
