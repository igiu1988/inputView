#import "WYRecorder.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface WYRecorder () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    NSTimer *timerForPitch;
    NSURL *recordedTmpFile;
}
@property (nonatomic, readonly, strong) AVAudioRecorder *recorder;

@end
@implementation WYRecorder

- (id)init{
    self = [super init];
    if (self) {
        //Instanciate an instance of the AVAudioSession object.
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        //Setup the audioSession for playback and record. 
        //We could just use record and then switch it to playback later, but
        //since we are going to do both lets set it up once.
        NSError *error = nil;
        [audioSession setCategory:AVAudioSessionCategoryRecord error: &error];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                   error:&error];
        [audioSession setActive:YES error: &error];
    }
    return self;
}


//+ (NSData *)waveDataFromARMData:(NSData *)data{
//    if (!data) {
//        return data;
//    }
//    return DecodeAMRToWAVE(data);
//
//}

// curAudio = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url],1,16);


#pragma mark - 录音操作
- (void)abortRecord
{
    [_recorder stop];
    if (![_recorder deleteRecording]) {
        NSLog(@"放弃录音失败");
    }
    
    [timerForPitch invalidate];
}

- (void)stopRecord {
    [_recorder stop];
    [timerForPitch invalidate];
}

- (void)startRecord {
    
    _recorder = nil;
    
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey, 
                                       [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       nil];
    
    recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
    NSLog(@"Using File called: %@",recordedTmpFile);

    NSError *error ;
    
    // Setup the recorder to use this file and record to it.
    _recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
    [_recorder setDelegate:self];

    if ([_recorder prepareToRecord] == YES){
        _recorder.meteringEnabled = YES;
        [_recorder record];
        
        timerForPitch =[NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }else {
        NSLog(@"Error: %@)" , [error localizedDescription]);
    }

    //Start the actual Recording
    [_recorder record];
}

// 在录音时被一个timer调用，以重复返回当前的录音平均电平
- (void)levelTimerCallback:(NSTimer *)timer {
	[_recorder updateMeters];
    
    // averagePowerForChannel的取值是0～-160，-160表示没有任何声音，转换为0~1
    double currentPower = pow(10, 0.05 * [_recorder averagePowerForChannel:0]);
    if (_periodicTimeBlock) {
        _periodicTimeBlock (currentPower, _recorder);
    }
}


#pragma mark - 录音的Delegate
/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (_recordFinish) {
        NSData *data = [NSData dataWithContentsOfURL:recordedTmpFile];
        _recordFinish(flag, data);
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    if (_recordFinish) {
        _recordFinish(NO, nil);
    }
}

@end
