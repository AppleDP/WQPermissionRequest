//
//  ViewController.m
//  WQPermissionRequest
//
//  Created by admin on 17/2/14.
//  Copyright © 2017年 jolimark. All rights reserved.
//

#import "ViewController.h"
#import "WQPermissionRequest.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)requestClick:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [SINGLETONREQUEST requestPermission:WQLocationWhenInUse
                                  title:@"请求开启网络权限"
                            description:@"开启网络权限"
                          requestResult:^(BOOL granted,
                                          NSError *error) {
                              if (error) {
                              }else {
                                  if (granted) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"权限已授权成功"
                                                                                                         message:@""
                                                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
                                          UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                                                       style:UIAlertActionStyleDefault
                                                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                                                     }];
                                          [alert addAction:ok];
                                          [weakSelf.navigationController presentViewController:alert
                                                                                      animated:YES
                                                                                    completion:nil];
                                      });
                                  }else {
                                  }
                              }
                          }];
}
@end





