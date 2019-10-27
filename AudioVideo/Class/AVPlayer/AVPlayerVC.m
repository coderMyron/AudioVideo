//
//  AVPlayerVC.m
//  AudioVideo
//
//  Created by Myron on 2019/10/26.
//  Copyright © 2019 Myron. All rights reserved.
//
/**
 AVPlayer没有是否正在播放的状态属性，通常情况下可以通过判断播放器的播放速度来获得播放状态。如果rate为0说明是停止状态，1是则是正常播放状态。
 在播放视频时，特别是播放网络视频往往需要知道视频加载情况、缓冲情况、播放情况，这些信息可以通过KVO监控AVPlayerItem的status、loadedTimeRanges属性来获得
 当AVPlayerItem的status属性为AVPlayerStatusReadyToPlay是说明正在播放，只有处于这个状态时才能获得视频时长等信息；当loadedTimeRanges的改变时（每缓冲一部分数据就会更新此属性）可以获得本次缓冲加载的视频范围（包含起始时间、本次加载时长），这样一来就可以实时获得缓冲情况
 */
#import "AVPlayerVC.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerVC ()

@property (nonatomic,strong) AVPlayer *player;//播放器对象
@property (weak, nonatomic) IBOutlet UIView *container; //播放器容器
@property (weak, nonatomic) IBOutlet UIButton *playOrPause; //播放/暂停按钮
@property (weak, nonatomic) IBOutlet UIProgressView *progress; //播放进度
@property(nonatomic,strong) id timeObserve;;

@end

@implementation AVPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self.player play];
    [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];

}

-(void)dealloc{
    NSLog(@"dealloc");
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
}
#pragma mark - 私有方法
-(void)setupUI{
    //创建播放器层
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame=self.container.bounds;
    playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;//视频填充模式
    [self.container.layer addSublayer:playerLayer];
}
 
/**
 *  截取指定时间的视频缩略图
 *
 */
/**
 *  初始化播放器
 *
 *  @return 播放器对象
 */
-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem:0];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
        [self addNotification];
    }
    return _player;
}
 
/**
 *  根据视频索引取得AVPlayerItem对象
 *
 *  @param videoIndex 视频顺序索引
 *
 *  @return AVPlayerItem对象
 */
-(AVPlayerItem *)getPlayItem:(int)videoIndex{
    NSString *urlStr;
    if (videoIndex == 0) {
        urlStr = @"http://121.199.61.174/testhtml5.mp4";
    }else if(videoIndex == 1){
        urlStr = @"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4";
    }else{
        urlStr = @"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4";
    }
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //播放网络
    NSURL *url=[NSURL URLWithString:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}

#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
 
/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    //播放完成后移除观察者
    [self removeObserverFromPlayerItem:self.player.currentItem];
}
 
#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    UIProgressView *progress=self.progress;
    //添加观察者 这里设置每秒执行一次
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        NSLog(@"当前已经播放%.2fs.",current);
        NSLog(@"total %.2fs.",total);
        if (current) {
            [progress setProgress:(current/total) animated:YES];
        }
        float rate = floor(current / total * 100)/100;
        NSLog(@"-- %f",rate);
        //播放本地音乐没有结束回调，用这个方法
        if (rate == 1.0f) {
            NSLog(@"监控播放进度结束");
            //[self removeObserverFromPlayerItem:self.player.currentItem];
        }
    }];
}
 
/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];//移除观察者
        self.timeObserve = nil;
        [playerItem removeObserver:self forKeyPath:@"status"];
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
}

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
//                self.status = SUPlayStatusReadyToPlay;
                NSLog(@"KVO：准备完毕，可以播放");
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
        NSLog(@"%@",change);
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
       
    }
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (IBAction)playClick:(UIButton *)sender {
    if(self.player.rate==0){ //说明时暂停
//        [sender setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
//        [sender setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [sender setTitle:@"播放" forState:UIControlStateNormal];
    }
}

/**
 *  切换选集，这里使用按钮的tag代表视频名称
 *
 *  @param sender 点击按钮对象
 */
- (IBAction)navigationButtonClick:(UIButton *)sender {
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    AVPlayerItem *playerItem=[self getPlayItem:sender.tag];
    [self addObserverToPlayerItem:playerItem];
    //切换视频
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self addNotification];
    [self addProgressObserver];
    if(self.player.rate==0){ //切换时暂停自动播放
        [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
        [self.player play];
    }
}

- (IBAction)playLocal:(UIButton *)sender {
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    //播放本地
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"test4.mp4" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    [self addObserverToPlayerItem:playerItem];
    //切换视频
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self addNotification];
    [self addProgressObserver];
    if(self.player.rate==0){ //切换时暂停自动播放
        [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
        [self.player play];
    }

}
- (IBAction)playSound:(UIButton *)sender {
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    //播放本地音乐
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"朴树 - 平凡之路.mp3" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    [self addObserverToPlayerItem:playerItem];
    //切换视频
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self addNotification];
    [self addProgressObserver];
    if(self.player.rate==0){ //切换时暂停自动播放
        [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
        [self.player play];
    }
}
- (IBAction)playHttpSound:(UIButton *)sender {
    [self removeNotification];
        [self removeObserverFromPlayerItem:self.player.currentItem];
        //播放网络音乐
        NSURL *url = [NSURL URLWithString:@"http://music.163.com/song/media/outer/url?id=447925558.mp3"];
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
        [self addObserverToPlayerItem:playerItem];
        //切换视频
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [self addNotification];
        [self addProgressObserver];
        if(self.player.rate==0){ //切换时暂停自动播放
            [self.playOrPause setTitle:@"暂停" forState:UIControlStateNormal];
            [self.player play];
        }
}

@end
