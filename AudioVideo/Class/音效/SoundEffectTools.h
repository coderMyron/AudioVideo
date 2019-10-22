//
//  SoundEffectTools.h
//  AudioVideo
//
//  Created by Myron on 2019/10/20.
//  Copyright © 2019 Myron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SoundEffectTools : NSObject

/**
 播放音效
 
 @param name 声音文件名(带后缀)
 @param alert 是否振动
 */
+ (void)playSoundWithName:(NSString *)name alert:(BOOL)alert;

//清除缓存
+ (void)clearMemory;

@end

NS_ASSUME_NONNULL_END
