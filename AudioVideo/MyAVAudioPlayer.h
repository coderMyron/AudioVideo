//
//  MyAVAudioPlayer.h
//  AudioVideo
//
//  Created by Myron on 2019/10/20.
//  Copyright © 2019 Myron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MyAVAudioPlayer;
@protocol MyAVAudioPlayerDelegate <NSObject>

-(void)updateProgress:(MyAVAudioPlayer *)player withProgress:(CGFloat)progress;

@end

@interface MyAVAudioPlayer : NSObject

@property(nonatomic,strong) AVAudioPlayer *player;
@property(nonatomic,assign) NSTimeInterval currentTime;
@property(nonatomic,assign) NSTimeInterval duration;
@property(nonatomic,weak) id<MyAVAudioPlayerDelegate> delegate;


-(instancetype)init;
+(instancetype)sharedAVAudioPlayer;
//通过传递的歌曲名称进行播放
-(void)playMusicWithMusicName:(NSString *)musicName;
//开始或暂停
-(void)playOrStopMusic;
-(BOOL)isPlaying;

@end

NS_ASSUME_NONNULL_END
