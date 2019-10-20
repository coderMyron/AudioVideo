//
//  AppDelegate.m
//  AudioVideo
//
//  Created by Myron on 2019/10/19.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"didFinishLaunchingWithOptions");
    /**
    想要接收播放控制消息，我们必须要做三件事：
    1成为Frist Responder
    2请求系统，要求开始监听播放控制消息（Remote Control Events）
    3开始播放音频。
     */

    //告诉系统，我们要接受远程控制事件
//    [[UIApplication  sharedApplication] beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];

    
    return YES;
}

//-(void)applicationWillResignActive:(UIApplication *)application
//{
//    NSLog(@"applicationWillResignActive");
//    AVAudioSession *session=[AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    //后台播放
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    NSLog(@"remoteControlReceivedWithEvent %ld",event.subtype);
    NSInteger order=-1;
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPause:
            order=UIEventSubtypeRemoteControlPause;
            break;
        case UIEventSubtypeRemoteControlPlay:
            order=UIEventSubtypeRemoteControlPlay;
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            order=UIEventSubtypeRemoteControlNextTrack;
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            order=UIEventSubtypeRemoteControlPreviousTrack;
            break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
            order=UIEventSubtypeRemoteControlTogglePlayPause;
            break;
        default:
            order=-1;
            break;
    }
    NSDictionary *orderDict=@{@"order":@(order)};
     [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveRemoteControlNotification object:nil userInfo:orderDict];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@"applicationDidEnterBackground");
}




@end
