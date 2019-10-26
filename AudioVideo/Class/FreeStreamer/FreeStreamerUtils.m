//
//  FreeStreamerUtils.m
//  AudioVideo
//
//  Created by Myron on 2019/10/26.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "FreeStreamerUtils.h"

@implementation FreeStreamerUtils

static FreeStreamerUtils *instance = nil;

+ (instancetype)shareFreeStreamer{
    //return [[self alloc]init];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
    
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;

}

-(id)copyWithZone:(NSZone *)zone{
    return instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return instance;
}

- (FSAudioStream *)audioStream{
    if (!_audioStream) {
//        NSURL *url=[self getFileUrl];
        //创建FSAudioStream对象
//        _audioStream=[[FSAudioStream alloc]initWithUrl:url];
        _audioStream = [[FSAudioStream alloc] init];
        _audioStream.onFailure=^(FSAudioStreamError error,NSString *description){
            NSLog(@"播放过程中发生错误，错误信息：%@",description);
        };
        _audioStream.onCompletion=^(){
            NSLog(@"播放完成!");
        };
        [_audioStream setVolume:0.5];//设置声音
        // 不进行检测格式 <开启检测之后，有些网络音频链接无法播放>
        //_audioStream.strictContentTypeChecking = NO;
        //_audioStream.defaultContentType = @"audio/mpeg";
    }
    return _audioStream;
}

@end
