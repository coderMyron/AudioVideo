//
//  MediaInfo.h
//  AudioVideo
//
//  Created by Myron on 2019/10/20.
//  Copyright © 2019 Myron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaInfo : NSObject

//歌名
@property(nonatomic,strong) NSString *musicName;

//歌手
@property(nonatomic,strong) NSString *artist;

//专辑
@property(nonatomic,strong) NSString *albumTitle;

//插图
@property(nonatomic,strong) NSString *artwork;

@property(nonatomic,strong) NSString *musicFile;

@end

NS_ASSUME_NONNULL_END
