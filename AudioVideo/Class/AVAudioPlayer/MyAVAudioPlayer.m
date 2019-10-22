//
//  MyAVAudioPlayer.m
//  AudioVideo
//
//  Created by Myron on 2019/10/20.
//  Copyright © 2019 Myron. All rights reserved.
//
/**
 AVAudioPlayer是通过一个文件路径来加载，AVAudioPlayer一次只能播放一个音频文件，所有上一曲、下一曲其实可以通过创建多个播放器对象来完成。AVAudioPlayer不支持加载网络媒体流，只能播放本地文件
 */

#import "MyAVAudioPlayer.h"

@interface MyAVAudioPlayer ()<AVAudioPlayerDelegate>

@property (weak ,nonatomic) NSTimer *timer;//进度更新定时器

@end

@implementation MyAVAudioPlayer

static NSMutableDictionary *cacheDict;

//第一次使用当前类的时候会执行(1. 只会执行一次 2. 你使用了这个类就会执行，不使用则不执行)
+ (void)initialize {
    NSLog(@"initialize");   //类的生命周期
    
    //初始化缓存字典
    cacheDict = [NSMutableDictionary dictionary];
}


-(instancetype)init{
    if (self == [super init]) {
        
    }
    return self;
}
#pragma mark 单例模式(避免同时播放多首歌)
+(instancetype)sharedAVAudioPlayer{
    static MyAVAudioPlayer *playerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerInstance = [[self alloc] init];
    });
    return playerInstance;
}

-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _timer;
}

/**
 *  更新播放进度
 */
-(void)updateProgress{
    float progress= self.player.currentTime /self.player.duration;
    if ([self.delegate respondsToSelector:@selector(updateProgress:withProgress:)]) {
        [self.delegate updateProgress:self withProgress:progress];
    }
}


-(void)playOrStopMusic{
    if ([self.player isPlaying]) {
        [self.player pause];
        self.timer.fireDate=[NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
        return;
    }
    [self.player play];
    self.timer.fireDate=[NSDate distantPast];//恢复定时器

}

#pragma mark 通过音乐名称播放音乐
-(void)playMusicWithMusicName:(NSString *)musicName{
    AVAudioPlayer * cachPlayer = cacheDict[musicName];
    if (!cachPlayer) {
        NSString *urlStr=[[NSBundle mainBundle]pathForResource:musicName ofType:nil];
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        if(self.player && self.player.isPlaying){
            [self.player stop];
        }
        [cacheDict removeAllObjects];
        self.player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
       // 设置播放器属性
        self.player.numberOfLoops=0;//设置为0不循环
        self.player.delegate=self;
        [self.player prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return;
        }
        
        [cacheDict setValue:self.player forKey:musicName];
        [self.player play];
        
        //设置后台播放模式
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
                [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [audioSession setActive:YES error:nil];
        //添加通知，拔出耳机后暂停播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    }else{
        self.player = cachPlayer;
        self.player.delegate=self;
        if (![self.player isPlaying]) {
            [self.player play];
//            self.player.fireDate=[NSDate distantPast];//恢复定时器
        }

    }
    self.timer.fireDate=[NSDate distantPast];//恢复定时器
//    return _player;
}

/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            if(self.player && self.player.isPlaying){
                [self.player pause];
            }
        }
    }
    
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSLog(@"%@:%@",key,obj);
        }];
}

- (BOOL)isPlaying{
    if (self.player) {
        return self.player.isPlaying;
    }
    return NO;
}

- (NSTimeInterval)currentTime{
    if (self.player) {
        return self.player.currentTime;
    }
    return 0;
}
- (NSTimeInterval)duration{
    if (self.player) {
        return self.player.duration;
    }
    return 0;

}

- (void)dealloc
{
    NSLog(@"player dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

#pragma mark - 播放器代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"audioPlayerDidFinishPlaying 音乐播放完成...");
    //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
    [[AVAudioSession sharedInstance]setActive:NO error:nil];
}

@end
