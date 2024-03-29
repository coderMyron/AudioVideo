//
//  MPMoviePlayerVC.m
//  AudioVideo
//
//  Created by Myron on 2019/10/26.
//  Copyright © 2019 Myron. All rights reserved.
//

/**
 IOS13 已经废弃了这MPMoviePlayerController MPMoviePlayerViewController
 'MPMoviePlayerController is no longer available. Use AVPlayerViewController in AVKit.'
 'MPMoviePlayerViewController is no longer available. Use AVPlayerViewController in AVKit.'
 */
#import "MPMoviePlayerVC.h"
#import <MediaPlayer/MediaPlayer.h>


@interface MPMoviePlayerVC ()

//@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器
@property (nonatomic,strong) MPMoviePlayerViewController *moviePlayerViewController;

@end

@implementation MPMoviePlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //播放
//    [self.moviePlayer play];
    
    //添加通知
    [self addNotification];

}

-(void)dealloc{
    //移除所有通知监控
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 私有方法
/**
 *  取得本地文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getFileUrl{
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"The New Look of OS X Yosemite.mp4" ofType:nil];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
 
/**
 *  取得网络文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getNetworkUrl{
    NSString *urlStr=@"http://192.168.1.161/The New Look of OS X Yosemite.mp4";
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}
 
/**
 *  创建媒体播放控制器
 *
 *  @return 媒体播放控制器
 */
//-(MPMoviePlayerController *)moviePlayer{
//    if (!_moviePlayer) {
//        NSURL *url=[self getNetworkUrl];
//        _moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:url];
//        _moviePlayer.view.frame=self.view.bounds;
//        _moviePlayer.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        [self.view addSubview:_moviePlayer.view];
//    }
//    return _moviePlayer;
//}

-(MPMoviePlayerViewController *)moviePlayerViewController{
    if (!_moviePlayerViewController) {
        NSURL *url=[self getNetworkUrl];
        _moviePlayerViewController=[[MPMoviePlayerViewController alloc]initWithContentURL:url];
        [self addNotification];
    }
    return _moviePlayerViewController;
}

 
/**
 *  添加通知监控媒体播放控制器状态
 */
-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayerViewController.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerViewController.moviePlayer];
    
}
 
/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.moviePlayerViewController.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");
            break;
        default:
            NSLog(@"播放状态:%li",self.moviePlayerViewController.moviePlayer.playbackState);
            break;
    }
}
 
/**
 *  播放完成
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    NSLog(@"播放完成.%li",self.moviePlayerViewController.moviePlayer.playbackState);
}
- (IBAction)play:(UIButton *)sender {
    self.moviePlayerViewController=nil;//保证每次点击都重新创建视频播放控制器视图，避免再次点击时由于不播放的问题
    [self presentViewController:self.moviePlayerViewController animated:YES completion:nil];
    //注意，在MPMoviePlayerViewController.h中对UIViewController扩展两个用于模态展示和关闭MPMoviePlayerViewController的方法，增加了一种下拉展示动画效果
    [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];

}

@end
