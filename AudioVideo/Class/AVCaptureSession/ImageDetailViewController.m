//
//  ImageDetailViewController.m
//  AudioVideo
//
//  Created by Myron on 2019/10/30.
//  Copyright © 2019 Myron. All rights reserved.
//

#import "ImageDetailViewController.h"

#define SelfWidth [UIScreen mainScreen].bounds.size.width
#define SelfHeight [UIScreen mainScreen].bounds.size.height

@interface ImageDetailViewController ()
{

UIImage *imageIm;
    
}
@end

@implementation ImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    float statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SelfWidth, SelfHeight)];
    imageView.image = [UIImage imageWithData:_data];
    [self.view addSubview:imageView];
    imageIm =[UIImage imageWithData:_data];
    CGSize originalsize = [ imageView.image size];

    NSLog(@"改变前图片的宽度为%f,图片的高度为%f",originalsize.width,originalsize.height);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(15, SelfHeight - 50, 40, 40);
    [button setTitle:@"重拍" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    //宽高3：1 这里用layer会向下偏移navigationbar的高度，所以用下面的view不会出现这种情况
//    CALayer *Mylayer=[CALayer layer];
//    Mylayer.bounds=CGRectMake(10, (SelfHeight - (SelfWidth - 20)/3)/2, SelfWidth - 20, (SelfWidth - 20)/3);
//    Mylayer.position=CGPointMake(SelfWidth/2, (SelfHeight - 120)/2);
//    Mylayer.masksToBounds=YES;
//    Mylayer.borderWidth=1;
//    Mylayer.borderColor=[UIColor whiteColor].CGColor;
//    [self.view.layer addSublayer:Mylayer];
    
    //宽高3：1
    UIView *border = [[UIView alloc] init];
    border.frame = CGRectMake(10, (SelfHeight - (SelfWidth - 20)/3)/2, SelfWidth - 20, (SelfWidth - 20)/3);
    border.layer.borderWidth = 1;
    border.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:border];
    
//    NSLog(@"view %@",NSStringFromCGRect(self.view.frame));
//    NSLog(@"%@",NSStringFromCGRect(Mylayer.frame));

    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightButton.frame = CGRectMake(SelfWidth - 90, SelfHeight - 50, 80, 40);
    [rightButton setTitle:@"使用照片" forState:UIControlStateNormal];
    [rightButton setTintColor:[UIColor whiteColor]];
    [rightButton addTarget:self action:@selector(rightButton) forControlEvents:UIControlEventTouchUpInside];
[self.view addSubview:rightButton];
}

-(void)rightButton{
    //截取照片，截取到自定义框内的照片
    imageIm = [self image:imageIm scaleToSize:CGSizeMake(SelfWidth, SelfHeight)];
    //应为在展开相片时放大的两倍，截取时也要放大两倍
    imageIm = [self imageFromImage:imageIm inRect:CGRectMake(10, (SelfHeight - (SelfWidth - 20) /3)/2, (SelfWidth - 20) , (SelfWidth - 20)/3)];
    
    //将图片存储到相册
     UIImageWriteToSavedPhotosAlbum(imageIm, self, nil, nil);
    
   //截取之后将图片显示在照相时页面，和拍摄时的照片进行像素对比
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(10, (SelfHeight - (SelfWidth - 20) /3)/2  + 200, SelfWidth - 20 , (SelfWidth - 20)/3)];
    imageView.image = imageIm;
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];

}

//截取图片
-(UIImage*)image:(UIImage *)imageI scaleToSize:(CGSize)size{
   /*
    UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
    CGSize size：指定将来创建出来的bitmap的大小
    BOOL opaque：设置透明YES代表透明，NO代表不透明
    CGFloat scale：代表缩放,0代表不缩放
    创建出来的bitmap就对应一个UIImage对象
    */
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0); //此处将画布放大两倍，这样在retina屏截取时不会影响像素
    
    [imageI drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
-(UIImage *)imageFromImage:(UIImage *)imageI inRect:(CGRect)rect{
    
    CGImageRef sourceImageRef = [imageI CGImage];
    NSLog(@"%f",[UIScreen mainScreen].scale);
    float scale = [UIScreen mainScreen].scale;
    CGRect rect2 = CGRectMake(rect.origin.x * scale , rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    //NSLog(@"%@",NSStringFromCGRect(rect2));
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect2);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CFRelease(newImageRef);
    return newImage;
}


-(void)back{
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
