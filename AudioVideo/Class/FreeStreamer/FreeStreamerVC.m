//
//  FreeStreamerVC.m
//  AudioVideo
//
//  Created by Myron on 2019/10/25.
//  Copyright © 2019 Myron. All rights reserved.
//

/**
 播放本地 网络都可以
 如果引用libxml2.dylib编译不通过，需要在Xcode的Targets-Build Settings-Header Search Path中添加$(SDKROOT)/usr/include/libxml2
 */

#import "FreeStreamerVC.h"
#import "FreeStreamerUtils.h"

@interface FreeStreamerVC ()

@property (nonatomic,strong) FSAudioStream *audioStream;
@property (weak, nonatomic) IBOutlet UIButton *playOrPause;
@property (weak, nonatomic) IBOutlet UISlider *progress;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property(nonatomic,weak) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UISlider *valumSlider;

@end

@implementation FreeStreamerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.progress addTarget:self action:@selector(progressChangeAction:) forControlEvents:UIControlEventValueChanged];
    [self.progress addTarget:self action:@selector(progressTouchBeginAction:) forControlEvents:(UIControlEventTouchDown)];
    [self.progress addTarget:self action:@selector(progressTouchEndAction:) forControlEvents:(UIControlEventTouchUpInside)];
    if (self.audioStream.isPlaying) {
        [self continueTimer];
    }else{
        [self updateTime];
    }
    [self.valumSlider addTarget:self action:@selector(valumChangeAction:) forControlEvents:UIControlEventValueChanged];
    self.valumSlider.value = self.audioStream.volume;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopTimer];
}
- (void)stopTimer
{
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


- (void)dealloc
{
    NSLog(@"dealloc");
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        
    }
    return _timer;
}

- (void)updateTime{
    //获取已经播放的时间
    int minute = self.audioStream.currentTimePlayed.minute;
    int second = self.audioStream.currentTimePlayed.second;
    NSString *currentTime = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    // 改变显示当前时间的标签文字
    self.currentTimeLabel.text = currentTime;
    
    int allMinute = self.audioStream.duration.minute;
    int allSecond = self.audioStream.duration.second;
    float totalSecond = allMinute * 60 + allSecond;
    float currentSecond = minute * 60 + second;
    
    [self.progress setValue:(currentSecond / totalSecond)];
}

- (void)pauseTimer{
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)continueTimer{
    self.timer.fireDate = [NSDate distantPast];
}

//调声音
- (void)valumChangeAction:(UISlider *)slider{
    self.audioStream.volume = slider.value;
}

- (void)progressChangeAction:(UISlider *)slider{
    float value = slider.value;
    // 进度 * 总时间 获取当前时间
    int minute = self.audioStream.duration.minute;
    int second = self.audioStream.duration.second;
    float totalTime = minute * 60 + second;
    float current = value * totalTime;
    // 当前分钟数
    double minutesElapsed =floor(current / 60);
    // 当前秒数 fmodc取余数
    double secondsElapsed =floor(fmod(current,60.0));
    // 格式化当前时间
    NSString *currentTime = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    // 改变显示当前时间的标签文字
    self.currentTimeLabel.text = currentTime;
}

// 开始改变进度
- (void)progressTouchBeginAction:(UISlider *)sender {
    NSLog(@"开始触摸");
    [self pauseTimer];
}
// 结束改变进度
- (void)progressTouchEndAction:(UISlider *)sender {
    NSLog(@"结束触摸");
    [self continueTimer];
    // 获取进度 0 ~ 1
    float value = sender.value == 0 ? 0.001 : sender.value;
    // 创建播放进度对象
    FSStreamPosition position;
    // 赋值
    position.position = value;
    // 跳转进度
    [self.audioStream seekToPosition:position];
}
- (IBAction)playHttp:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:@"http://music.163.com/song/media/outer/url?id=447925558.mp3"];
    [self.audioStream playFromURL:url];
    self.timer.fireDate=[NSDate distantPast];
}

- (IBAction)playLocal:(UIButton *)sender {
    //而是初始化完成之后开始播放音频
    [self.audioStream play];
    NSURL *url=[self getFileUrl];
    [self.audioStream playFromURL:url];
    self.timer.fireDate=[NSDate distantPast];

}
- (IBAction)pause:(UIButton *)sender {
    //音频暂停之后继续调用pause方法即可恢复播放
    if (self.audioStream.isPlaying) {
        [self.playOrPause setTitle:@"播放" forState:UIControlStateNormal];
    }else{
         [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
    }
    [self.audioStream pause];
}

/**
上一曲 / 下一曲
使用[self.audioStream playFromURL:url]直接切换音频链接即可
 */
- (IBAction)nextSound:(UIButton *)sender {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"赵雷 - 我们的时光.mp3" ofType:nil]];
    [self.audioStream playFromURL:url];
}

//快退
- (IBAction)seekToBack:(UIButton *)sender {
    
}

//快进
- (IBAction)seekToGo:(UIButton *)sender {
    
}


/**
 *  创建FSAudioStream对象
 *
 *  @return FSAudioStream对象
 */
-(FSAudioStream *)audioStream{
    if (!_audioStream) {
        _audioStream = FreeStreamerUtils.shareFreeStreamer.audioStream;
    }
    return _audioStream;
}

/**
 *  取得本地文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getFileUrl{
    NSString *urlStr=[[NSBundle mainBundle]pathForResource:@"朴树 - 平凡之路.mp3" ofType:nil];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}



@end
