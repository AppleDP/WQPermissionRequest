//
//  WQPermissionRequest.h
//  WQPermissionRequest
//
//  Created by admin on 17/2/14.
//  Copyright © 2017年 jolimark. All rights reserved.
//



#import <Foundation/Foundation.h>

#define WQLocalized(key) NSLocalizedStringFromTable(key, @"WQLocalized", nil)
#define WQREQUESTOBJ [WQPermissionRequest createWQPermissionRequest]
#define WQErrorDomain @"WQErrorDomain"

#ifndef WQPermissionLogEnable
#define WQPermissionLogEnable 1
#endif

#if WQPermissionLogEnable
/* 
 日志输出到控制台须要导入 WQLog.h 日志输出类
 https://github.com/AppleDP?tab=repositories
*/
#import "WQLog.h"
#else
#define WQLogDef(FORMAT,...) {}
#define WQLogInf(FORMAT,...) {}
#define WQLogErr(FORMAT,...) {}
#define WQLogWar(FORMAT,...) {}
#define WQLogMes(FORMAT,...) {}
#define WQLogOth(FORMAT,...) {}
#endif

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
    WQNetwork,             // 网络
}WQPermission;

typedef enum {
    WQForbidPermission,
    WQFailueAuthorize,
    WQUnsuportAuthorize
}WQErrorCode;

typedef void(^WQRequestResult)(BOOL granted, NSError *error);

@interface WQPermissionRequest : NSObject
+ (WQPermissionRequest *)createWQPermissionRequest;

/**
 *  判断权限是否存在
 *
 *  @param permission 权限类型
 *
 *  @return 权限是否存在
 */
- (BOOL)determinePermission:(WQPermission)permission;

/**
 *  获得当前活动视图控制器
 *
 *  @return 当前活动视图控制器
 */
- (UIViewController *)currentViewController;

/**
 *  权限是否存在,如果权限不存在则请求权限
 *
 *  @param permission  权限类型
 *  @param title       非第一次请求权限时标题
 *  @param description 非第一次请求权限时副标题
 *  @param result      请求结果
 */
- (void)requestPermission:(WQPermission)permission
                    title:(NSString *)title
              description:(NSString *)description
            requestResult:(WQRequestResult)result;
@end











