//
//  AVAudioPlayerViewController.h
//  AudioVideo
//
//  Created by Myron on 2019/10/20.
//  Copyright © 2019 Myron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioPlayerViewController : UIViewController

@property(nonatomic,strong) MediaInfo *mediaInfo;

@end

NS_ASSUME_NONNULL_END
