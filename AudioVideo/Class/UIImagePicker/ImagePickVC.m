//
//  ImagePickVC.m
//  AudioVideo
//
//  Created by Myron on 2019/10/27.
//  Copyright © 2019 Myron. All rights reserved.
//
/**
 UIImagePickerCongtroller显示中文：
 修改Target-->Info-->Localization native development region 的值为China;要是还不行，需要设置Project-->info-->Localizations Language添加Chinese才行
 
 */
#import "ImagePickVC.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>



@interface ImagePickVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (assign,nonatomic) int isVideo; //是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *photo; //照片展示视图
@property (strong,nonatomic) AVPlayer *player; //播放器，用于录制完视频后播放视频
@property(nonatomic,assign) BOOL takeVideoing;

@end

@implementation ImagePickVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通过这里设置当前程序是拍照还是录制视频
    _isVideo=YES;

}

#pragma mark - UI事件
//点击拍照按钮
- (IBAction)takeClick:(UIButton *)sender {
    _imagePicker = nil;
    if(sender.tag == 1){
        _isVideo=YES;
    }else{
        _isVideo=NO;
    }
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}
 
#pragma mark - UIImagePickerController代理方法
//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage]; //获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage]; //获取原始照片
        }
        [self.photo setImage:image]; //显示照片
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); //保存到相簿
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){ //如果是录制视频
        NSLog(@"video...");
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL]; //视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
             //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil); //保存视频到相簿
        }
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
 
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
    [self dismissViewControllerAnimated:YES completion:nil];
}
 
#pragma mark - 私有方法
-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker=[[UIImagePickerController alloc]init];
        //设置image picker的来源，这里设置为摄像头
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            
        }
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            //设置使用哪个摄像头，这里设置为后置摄像头
            _imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
        }

        
        if (self.isVideo) {
            //媒体类型,默认情况下此数组包含kUTTypeImage，所以拍照时可以不用设置；
            //但是当要录像的时候必须设置，可以设置为kUTTypeVideo（视频，但不带声音）
            //或者kUTTypeMovie（视频并带有声音）
            _imagePicker.mediaTypes=@[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
            //设置摄像头模式（拍照，录制视频）
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
            _imagePicker.videoMaximumDuration = 10;
        }else{
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
        }
//        _imagePicker.allowsEditing = YES;//允许编辑
        _imagePicker.delegate = self;//设置代理，检测操作
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor redColor];
        CGSize size = [UIScreen mainScreen].bounds.size;
        view.frame =CGRectMake(0, 0, size.width, 100);
        //自定义取消
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        cancel.frame = CGRectMake(10, 10, 80, 40);
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(cancelImagePicker) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:cancel];
        //定义义拍照
        UIButton *takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        takePhoto.frame = CGRectMake(100, 10, 80, 40);
        [takePhoto setTitle:@"拍照" forState:UIControlStateNormal];
        [takePhoto setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [takePhoto addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:takePhoto];
        //定义义录视频
        UIButton *takeVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        takeVideo.frame = CGRectMake(180, 10, 80, 40);
        [takeVideo setTitle:@"录视频" forState:UIControlStateNormal];
        [takeVideo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [takeVideo addTarget:self action:@selector(takeVideo) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:takeVideo];

        //摄像头上覆盖的视图，可用通过这个视频来自定义拍照或录像界面
        _imagePicker.cameraOverlayView = view;
        //是否显示摄像头控制面板，默认为YES
        //_imagePicker.showsCameraControls = NO;
        //闪光灯模式 UIImagePickerControllerCameraFlashModeOn
        _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    }
    return _imagePicker;
}

-(void)cancelImagePicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)takePhoto{
    [self.imagePicker takePicture];
    NSLog(@"拍照");
}

-(void)takeVideo{
    if (!self.takeVideoing) {
        NSLog(@"开始录视频");
        self.takeVideoing = YES;
        [self.imagePicker startVideoCapture];
    }else{
        NSLog(@"结束录视频");
        self.takeVideoing = NO;
        [self.imagePicker stopVideoCapture];
    }
    
}
 
//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame=self.photo.frame;
        [self.photo.layer addSublayer:playerLayer];
        [_player play];
        
    }
}

@end
