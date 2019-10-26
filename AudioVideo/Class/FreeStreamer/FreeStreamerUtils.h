//
//  FreeStreamerUtils.h
//  AudioVideo
//
//  Created by Myron on 2019/10/26.
//  Copyright © 2019 Myron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSAudioStream.h"


NS_ASSUME_NONNULL_BEGIN

@interface FreeStreamerUtils : NSObject<NSCopying,NSMutableCopying>

+(instancetype)shareFreeStreamer;

@property (nonatomic,strong) FSAudioStream *audioStream;

@end

NS_ASSUME_NONNULL_END
