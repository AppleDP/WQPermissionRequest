//
//  ViewController.m
//  WQPermissionRequest
//
//  Created by admin on 17/2/14.
//  Copyright © 2017年 jolimark. All rights reserved.
//

#import "ViewController.h"

#import "WQPermissionRequest/WQPermissionRequest.h"

@interface ViewController ()
<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (nonatomic, strong) WQPermissionRequest *permissionRequest;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)requestClick:(UIButton *)sender {
    if (!self.permissionRequest) {
        self.permissionRequest = WQREQUESTOBJ;
    }
    __weak typeof(self) weakSelf = self;
    WQPermission permission = WQPhotoLibrary;
    [self.permissionRequest requestPermission:permission
                                        title:@"请求开启相册权限"
                                  description:@"开启相册权限"
                                requestResult:^(BOOL granted,
                                                NSError *error) {
                                    if (error) {
//                                        WQLogErr(@"error: %@",error);
                                    }else {
                                        if (granted) {
//                                            WQLogMes(@"请求成功");
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [weakSelf openPhotoLibrary];
                                            });
                                        }else {
//                                            WQLogMes(@"请求失败");
                                        }
                                    }
                                }];
}

-(void)openPhotoLibrary{
    // 进入相册
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
            NSLog(@"打开相册");
        }];
    }else {
        NSLog(@"不能打开相册");
        
    }
}
@end





