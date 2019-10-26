//
//  AVAssetImageVC.m
//  AudioVideo
//
//  Created by Myron on 2019/10/26.
//  Copyright © 2019 Myron. All rights reserved.
//
/**
 AVFoundation生成缩略图
 使用AVAssetImageGenerator获取缩略图大致分为三个步骤：
 创建AVURLAsset对象（此类主要用于获取媒体信息，包括视频、声音等）。
 根据AVURLAsset创建AVAssetImageGenerator对象。
 使用AVAssetImageGenerator的copyCGImageAtTime::方法获得指定时间点的截图。
 
 Privacy - Photo Library Additions Usage Descriptionc 权限
 */

#import "AVAssetImageVC.h"
#import <AVFoundation/AVFoundation.h>


@interface AVAssetImageVC ()

@end

@implementation AVAssetImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)keepThumbnailImage:(UIButton *)sender {
    //获取第13.0s的缩略图
    [self thumbnailImageRequest:13.0];
}
- (IBAction)localThumbnail:(UIButton *)sender {
    [self thumbnailImageRequestLocal:5];
}

#pragma mark - 私有方法
/**
 *  取得本地文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getFileUrl{
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"test4.mp4" ofType:nil];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
 
/**
 *  取得网络文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getNetworkUrl{
    NSString *urlStr=@"http://121.199.61.174/testhtml5.mp4";
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}
 
/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */
-(void)thumbnailImageRequest:(CGFloat )timeBySecond{
    //创建URL
    NSURL *url=[self getNetworkUrl];
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
 
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error=nil;
    CMTime time=CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
 
    CMTime actualTime;
    CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    CMTimeShow(actualTime);
    UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil);
    CGImageRelease(cgImage);
}

/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */
-(void)thumbnailImageRequestLocal:(CGFloat )timeBySecond{
    //创建URL
    NSURL *url=[self getFileUrl];
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
 
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error=nil;
    CMTime time=CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
 
    CMTime actualTime;
    CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    CMTimeShow(actualTime);
    UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil);
    CGImageRelease(cgImage);
}

@end
