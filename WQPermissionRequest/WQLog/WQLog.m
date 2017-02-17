//
//  WQLog.m
//  WQLog
//
//  Created by admin on 16/8/25.
//  Copyright © 2016年 jolimark. All rights reserved.
//

#import "WQLog.h"

@interface WQLog ()

@end

@implementation WQLog
static UIColor *WQCustomColor;
+ (void)setCustomColor:(UIColor *)color {
    WQCustomColor = color;
}

+ (void)recodeLog{
    NSLog(@"******************************************* 开 启 日 志 *******************************************");
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:@"WQLog.log"];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    NSLog(@" ");
    NSLog(@" ");
    NSLog(@" ");
    NSLog(@"********************** 日 志 %@ **********************",timeNow);
}

+ (void)clearRecode{
    NSLog(@"******************************************* 清 除 日 志 *******************************************");
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:@"WQLog.log"];
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:path
                                               error:&err];
}


+ (void)cusLog:(NSString *)file
          line:(int)line
        thread:(NSString *)thread
           log:(NSString *)log,... {
    if (WQCustomColor == nil) {
        WQCustomColor = [UIColor colorWithRed:0
                                        green:0
                                         blue:0
                                        alpha:0];
    }
    [self log:WQCustomColor
         file:file
         line:line
       thread:thread
          log:log];
}

+ (void)log:(UIColor *)color
       file:(NSString *)file
       line:(int)line
     thread:(NSString *)thread
        log:(NSString *)log,... {
    va_list list;
    if (log) {
        int r = 0, g = 0, b = 0;
        if (color) {
            const CGFloat *components = CGColorGetComponents(color.CGColor);
            r = components[0]*255;
            g = components[1]*255;
            b = components[2]*255;
        }
        va_start(list, log);
        NSString *msg = [[NSString alloc] initWithFormat:log
                                               arguments:list];
        va_end(list);
        NSLog((@"%@"
               @"%@" @">> >> >> 文件: %@ --- 行号: %d --- 线程: %@ --- 日志: %@ << << <<"
               @"%@"),
              color == nil ? @"" : XCODE_COLORS_ESCAPE,
              color == nil ? @"" : [NSString stringWithFormat:@"fg%d,%d,%d;",r,g,b],
              file,
              line,
              thread,
              msg,
              color == nil ? @"" : XCODE_COLORS_RESET_FG);
    }
}
@end



