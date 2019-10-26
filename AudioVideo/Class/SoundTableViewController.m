//
//  SoundTableViewController.m
//  AudioVideo
//
//  Created by Myron on 2019/10/19.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "SoundTableViewController.h"
#import "SoundEffectViewController.h"
#import "AVAudioPlayerViewController.h"
#import "MusicPlayerViewController.h"
#import "AVAudioRecorderVC.h"
#import "FreeStreamerVC.h"
#import "AVPlayerVC.h"
#import "AVAssetImageVC.h"

@interface SoundTableViewController ()

@end

@implementation SoundTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:{
            SoundEffectViewController *soundEffectVC = [[SoundEffectViewController alloc] init];
            [self.navigationController pushViewController:soundEffectVC animated:YES];
            break;
        }
        case 1:{
            AVAudioPlayerViewController *vc = [[AVAudioPlayerViewController alloc] init];
            MediaInfo *mediainfo = [[MediaInfo alloc] init];
            mediainfo = [[MediaInfo alloc] init];
            mediainfo.musicName = @"平凡之路";
            mediainfo.artist = @"朴树";
            mediainfo.artwork = @"showpic";
            mediainfo.albumTitle = @"树神";
            mediainfo.musicFile = @"朴树 - 平凡之路.mp3";
            [vc setMediaInfo:mediainfo];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:{
            AVAudioPlayerViewController *vc = [[AVAudioPlayerViewController alloc] init];
            MediaInfo *mediainfo = [[MediaInfo alloc] init];
            mediainfo = [[MediaInfo alloc] init];
            mediainfo.musicName = @"我们的时光";
            mediainfo.artist = @"赵雷";
            mediainfo.artwork = @"zaolei.jpg";
            mediainfo.albumTitle = @"雷神";
            mediainfo.musicFile = @"赵雷 - 我们的时光.mp3";
            [vc setMediaInfo:mediainfo];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:{
            //        MusicPlayerViewController *vc = [[MusicPlayerViewController alloc] init];
            //        MusicPlayerViewController *vc = [[MusicPlayerViewController alloc] initWithNibName:@"MusicPlayerVC" bundle:nil];
            MusicPlayerViewController *vc = [[MusicPlayerViewController alloc] initWithNibName:@"MusicPlayerVC" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 4:{
            AVAudioRecorderVC *vc = [[AVAudioRecorderVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 5:{
            FreeStreamerVC *vc = [[FreeStreamerVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 6:{
            AVPlayerVC *vc = [[AVPlayerVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 7:{
            AVAssetImageVC *vc = [[AVAssetImageVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
