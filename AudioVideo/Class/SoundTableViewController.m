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

@interface SoundTableViewController ()

@end

@implementation SoundTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 5;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
//
//    // Configure the cell...
//
//    return cell;
//}
//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        SoundEffectViewController *soundEffectVC = [[SoundEffectViewController alloc] init];
        [self.navigationController pushViewController:soundEffectVC animated:YES];
    }else if(indexPath.row == 1){
        AVAudioPlayerViewController *soundEffectVC = [[AVAudioPlayerViewController alloc] init];
        MediaInfo *mediainfo = [[MediaInfo alloc] init];
        mediainfo = [[MediaInfo alloc] init];
        mediainfo.musicName = @"平凡之路";
        mediainfo.artist = @"朴树";
        mediainfo.artwork = @"showpic";
        mediainfo.albumTitle = @"树神";
        mediainfo.musicFile = @"朴树 - 平凡之路.mp3";
        [soundEffectVC setMediaInfo:mediainfo];
        [self.navigationController pushViewController:soundEffectVC animated:YES];
    }else if(indexPath.row == 2){
        AVAudioPlayerViewController *soundEffectVC = [[AVAudioPlayerViewController alloc] init];
        MediaInfo *mediainfo = [[MediaInfo alloc] init];
        mediainfo = [[MediaInfo alloc] init];
        mediainfo.musicName = @"我们的时光";
        mediainfo.artist = @"赵雷";
        mediainfo.artwork = @"zaolei.jpg";
        mediainfo.albumTitle = @"雷神";
        mediainfo.musicFile = @"赵雷 - 我们的时光.mp3";
        [soundEffectVC setMediaInfo:mediainfo];
        [self.navigationController pushViewController:soundEffectVC animated:YES];
    }
}

@end
