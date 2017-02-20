# WQPermissionRequest
权限判定及手动请求权限
# Usage
### 支持权限类型
```objective-c 
typedef enum {
    WQPhotoLibrary,        // 相册
    WQCamera,              // 相机
    WQMicrophone,          // 麦克风
    WQLocationAllows,      // 始终定位
    WQLocationWhenInUse,   // 使用时定位
    WQCalendars,           // 日历
    WQReminders,           // 提醒事项
    WQHealth,              // 健康更新
    WQUserNotification,    // 通知
    WQContacts,            // 通讯录
}WQPermission;
```
### 权限请求
```objective-c
[self.permissionRequest requestPermission:WQPhotoLibrary
                                        title:@"请求开启相册权限"
                                  description:@"开启相册权限"
                                requestResult:^(BOOL granted,
                                                NSError *error) {
                                    if (error) {
//                                        WQLogErr(@"error: %@",error);
                                    }else {
                                        if (granted) {
//                                            WQLogMes(@"请求成功");
                                        }else {
//                                            WQLogMes(@"请求失败");
                                        }
                                    }
                                }];
```
### 权限判定
```objective-c
[self.permissionRequest determinePermission:WQPhotoLibrary];
```
