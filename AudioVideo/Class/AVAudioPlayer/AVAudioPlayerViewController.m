//
//  AVAudioPlayerViewController.m
//  AudioVideo
//
//  Created by Myron on 2019/10/20.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "AVAudioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MediaInfo.h"
#import "MyAVAudioPlayer.h"


@interface AVAudioPlayerViewController ()<MyAVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//播放器
@property (weak, nonatomic) IBOutlet UIProgressView *playProgress;//播放进度
@property (weak, nonatomic) IBOutlet UILabel *musicSinger; //演唱者
//播放/暂停按钮(如果tag为0认为是暂停状态，1是播放状态)
@property (weak, nonatomic) IBOutlet UIButton *playOrPause;

@end

@implementation AVAudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    //注册接收到远程控制的通知：
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listeningRemoteControl:) name:kAppDidReceiveRemoteControlNotification object:nil];
    
    [[MyAVAudioPlayer sharedAVAudioPlayer] playMusicWithMusicName:self.mediaInfo.musicFile];
    [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
    [self centerInfo:self.mediaInfo];
    [MyAVAudioPlayer sharedAVAudioPlayer].delegate = self;
    
}

- (void)setMediaInfo:(MediaInfo *)mediaInfo{
    _mediaInfo = mediaInfo;
}

/**
 *  显示当面视图控制器时注册远程事件
 *
 *  @param animated 是否以动画的形式显示
 */
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //开启远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //作为第一响应者
    [self becomeFirstResponder];
}
 
/**
 *  当前控制器视图不显示时取消远程控制
 *
 *  @param animated 是否以动画的形式消失
 */
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //退出当前控制器是否不显示远程控制根据需求
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

/**
 *  初始化UI
 */
-(void)setupUI{
    self.title=self.mediaInfo.musicName;
    self.musicSinger.text=self.mediaInfo.artist;
}
 
/**
 *  播放音频
 */
-(void)play{
    [[MyAVAudioPlayer sharedAVAudioPlayer] playOrStopMusic];
    [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
}
 
/**
 *  暂停播放
 */
-(void)pause{
    [[MyAVAudioPlayer sharedAVAudioPlayer] playOrStopMusic];
    [self.playOrPause setTitle:@"播放" forState:UIControlStateNormal];
}



- (IBAction)playClick:(UIButton *)sender {
    
    if([[MyAVAudioPlayer sharedAVAudioPlayer] isPlaying]){
//           [sender setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
//           [sender setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
        [self pause];
    }else{
//           [sender setImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
//           [sender setImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
        [self play];
    }
}

-(void)dealloc{
    NSLog(@"dealloc");

//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppDidReceiveRemoteControlNotification object:nil];
}

- (void)centerInfo:(MediaInfo *)mediaInfo{
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    UIImage *image = [UIImage imageNamed:mediaInfo.artwork];
    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
    //歌曲名称
    [songInfo setObject:mediaInfo.musicName forKey:MPMediaItemPropertyTitle];
    //演唱者
    [songInfo setObject:mediaInfo.artist forKey:MPMediaItemPropertyArtist];
    //专辑名
    [songInfo setObject:mediaInfo.albumTitle forKey:MPMediaItemPropertyAlbumTitle];
    //专辑缩略图
    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
    [songInfo setObject:[NSNumber numberWithDouble:[MyAVAudioPlayer sharedAVAudioPlayer].currentTime ] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经播放时间
    [songInfo setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];//进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
    [songInfo setObject:[NSNumber numberWithDouble:[MyAVAudioPlayer sharedAVAudioPlayer].duration] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲总时间设置
    
    //        设置锁屏状态下屏幕显示音乐信息
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];

}

//实现接收到通知的方法
-(void)listeningRemoteControl:(NSNotification *)sender
{
NSDictionary *dict=sender.userInfo;
NSInteger order=[[dict objectForKey:@"order"] integerValue];
switch (order) {
    //暂停
    case UIEventSubtypeRemoteControlPause:
    {
        [self pause];
        break;
    }
    //播放
    case UIEventSubtypeRemoteControlPlay:
    {
        [self play];
        break;
    }
    //暂停播放切换
    case UIEventSubtypeRemoteControlTogglePlayPause:
    {
        break;
    }
    //下一首
    case UIEventSubtypeRemoteControlNextTrack:
    {
        
        break;
    }
    //上一首
    case UIEventSubtypeRemoteControlPreviousTrack:
    {

        break;
    }
    default:
        break;
    }
}

#pragma mark - MyAVAudioPlayerDelegate
- (void)updateProgress:(MyAVAudioPlayer *)player withProgress:(CGFloat)progress{
    [self.playProgress setProgress:progress animated:true];
}


@end
