//
//  SoundEffectTools.m
//  AudioVideo
//
//  Created by Myron on 2019/10/20.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "SoundEffectTools.h"
#import <AVFoundation/AVFoundation.h>


//全局的静态变量(static修饰符：静态变量，只能分配一次内存，即只能初始化一次，只会开辟一次内存空间，不会反复重新加载内存)
//音效缓存字典(key: 文件名name, value: soundID)
static NSMutableDictionary *cacheDict;

@interface SoundEffectTools()

//静态方法中是无法访问属性的，改用C的静态变量
//@property(nonatomic, strong) NSMutableDictionary *cacheDict;

@end

@implementation SoundEffectTools

//第一次加载当前类(类被加载到内存中)的时候会先执行load方法(1. 只会执行一次 2. 一旦你创建了这一个文件就会在编译时调用，与你是否使用它无关)
+ (void)load {
    NSLog(@"load");
}

//第一次使用当前类的时候会执行(1. 只会执行一次 2. 你使用了这个类就会执行，不使用则不执行)
+ (void)initialize {
    NSLog(@"initialize");   //类的生命周期
    
    //初始化缓存字典
    cacheDict = [NSMutableDictionary dictionary];
}

/**
 播放系统音效
 
 @param name 音效的文件名(带后缀)
 @param alert 是否振动
 */
+ (void)playSoundWithName:(NSString *)name alert:(BOOL)alert {

    /**
     1. 以name为Key, SoundID为Value
     2. 先判断缓存字典对一个的Value是否有值 --> soundID == 0 就代表没有值/没有缓存
     3. 没有值就创建, 有的话直接播放
     */
    
    //1. 创建系统音效soundID
    SystemSoundID soundid = [cacheDict[name] unsignedIntValue];
    
    //2. 先检查该文件是否在当前缓存文件中(为0代表没有在缓存中，那就去创建)
    if (soundid == 0) {
        //1. 创建音效类
        //1.1 获取包中音效文件的url路径
        NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
        
        //1.2 音效的播放是由系统底层来播放(基于C的接口)
        ///传入音频路径url就会和soundID进行绑定，之后需要播放的时候, 只需要调用soundID, 就能找到对应的URL地址
        ///这样做的好处就是soundID对音效有一个缓存，当音效文件第一次加载时，系统会将音效文件随机分配一个soundID，可以在下次播放时直接使用soundID播放，而无需再次获取对应的url地址
        AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundid);
        
        //1.3 将文件名与soundid加入到缓存字典中
        [cacheDict setValue:@(soundid) forKey:name];
    }
    
    //3. 播放音效(音效: 不超过30s的短音乐)
    ///播放音效有两种类型，一种是带振动(必须要真机)，一种不带振动
    if (alert) {
        //带振动
        AudioServicesPlayAlertSound(soundid);
        
    }else {
        //不带振动
        AudioServicesPlaySystemSound(soundid);
    }
}

+ (void)clearMemory {
    //1. 静态变量字典在ARC下面释放内存不能直接设置为nil，应该先清除内部对象
    [cacheDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //2. 清除静态字典内部的缓存
        ///ARC只对OC对象有效，对C对象无效(这就是为什么C对象至今仍保留了retain和release方法)
        //2.1 获取缓存的soundID
        SystemSoundID soundID = [obj unsignedIntValue];
        //2.2 C对象要释放一般使用CFRelease()，注意是释放C对象(堆里)，而soundID是UInt32类型(栈里)，所以看出有一些特殊的系统类内部会给出单独的API用于释放，此时应优先使用系统给出的单独的API，而不能一味套用CFRelease()
        //Dispose: 处理int类型的栈内存不能直接使用release
        AudioServicesDisposeSystemSoundID(soundID);
        
    }];
    //3. 移除字典所有元素
    [cacheDict removeAllObjects];
}

@end
