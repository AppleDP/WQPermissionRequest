//
//  WQLog.h
//  WQLog
//
//  Created by admin on 16/8/25.
//  Copyright © 2016年 jolimark. All rights reserved.
//

#import <UIKit/UIKit.h>

#define XCODE_COLORS_ESCAPE @"\033[" 
#define XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"fg;"

/*********************************** 安 装 了 XcodeColors 后 可 以 输 出 带 颜 色 的 日 志 ***********************************/
#define WQLogDef(FORMAT,...) WQLoger(nil,(FORMAT), ## __VA_ARGS__)
#define WQLogInf(FORMAT,...) WQLoger(WQColor(32,102,235,1),(FORMAT), ## __VA_ARGS__)
#define WQLogErr(FORMAT,...) WQLoger(WQColor(255,0,0,1),(FORMAT), ## __VA_ARGS__)
#define WQLogWar(FORMAT,...) WQLoger(WQColor(213,184,109,1),(FORMAT), ## __VA_ARGS__)
#define WQLogMes(FORMAT,...) WQLoger(WQColor(127,255,0,1),(FORMAT), ## __VA_ARGS__)
#define WQLogOth(FORMAT,...) WQLoger(WQColor(186,0,255,1),(FORMAT), ## __VA_ARGS__)
#define WQLoger(COLOR,FORMAT,...)   \
    [WQLog log:COLOR    \
          file:[[NSString stringWithUTF8String:__FILE__] lastPathComponent]   \
          line:__LINE__   \
        thread:[[NSThread currentThread] isMainThread] ? @"Main" : ([[NSThread currentThread].name  isEqual: @""] ? @"Child" : [NSThread currentThread].name) \
           log:(FORMAT), ## __VA_ARGS__]

/** 自定义颜色日志输出 */
#define WQLogCus(FORMAT,...) \
    [WQLog cusLog:[[NSString stringWithUTF8String:__FILE__] lastPathComponent]    \
             line:__LINE__    \
           thread:[[NSThread currentThread] isMainThread] ? @"Main" : ([[NSThread currentThread].name  isEqual: @""] ? @"Child" : [NSThread currentThread].name)  \
              log:(FORMAT), ## __VA_ARGS__]

#define WQColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface WQLog : NSObject
/**
 *  将日志输出到本地
 */
+ (void)recodeLog;
/**
 *  清除本地日志
 */
+ (void)clearRecode;
/**
 *  自定义日志颜色
 *
 *  @param color 日志颜色
 */
+ (void)setCustomColor:(UIColor *)color;





/*********************************** 内 部 调 用 ***********************************/
+ (void)log:(UIColor *)color
       file:(NSString *)file
       line:(int)line
     thread:(NSString *)thread
        log:(NSString *)log,...;
+ (void)cusLog:(NSString *)file
          line:(int)line
        thread:(NSString *)thread
           log:(NSString *)log,...;
@end










