//
//  LrcDataTool.m
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "LrcDataTool.h"
#import "LrcModel.h"
#import "TimeTool.h"

@implementation LrcDataTool

+ (NSArray<LrcModel *> *)getLrcData:(NSString *)filename{
    // 1.文件路径
    NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    if (!path) {
        return nil;
    }
    // 2.加载文件里的内容
    NSString * lrcContent = @"";
    NSError * error = nil;
    lrcContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    
    // 3.解析歌词
    // 3.1 将歌词转成数组
    /*
     [ti:心碎了无痕]
     [ar:张学友]
     [al:]
     
     [00:01.79]心碎了无痕
     [00:02.94]作词:MICHEAL 作曲:吴旭文
     [00:04.16]演唱：张学友
     */
    NSArray *lrcStrArray = [lrcContent componentsSeparatedByString:@"\n"];
    __block NSMutableArray<LrcModel *>* lrcMs = [NSMutableArray arrayWithCapacity:1];
    [lrcStrArray enumerateObjectsUsingBlock:^(NSString * lrcStr, NSUInteger idx, BOOL * _Nonnull stop) {
        // 过滤垃圾数据
        /*
         [ti:]
         [ar:]
         [al:]
         */
        BOOL isNoUseData = [lrcStr containsString:@"[ti:"] || [lrcStr containsString:@"[ar:"] || [lrcStr containsString:@"[al:"];
        if (!isNoUseData) {
            LrcModel * lrcModel = [[LrcModel alloc] init];
            [lrcMs addObject:lrcModel];
            // 解析 [00:00.89]传奇
            // 去掉 [
            NSString * resutlStr = [lrcStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
            NSArray * timeAndContent = [resutlStr componentsSeparatedByString:@"]"];
            if (timeAndContent.count == 2) {
                NSString * time = [timeAndContent objectAtIndex:0];
                lrcModel.beginTime = [TimeTool getTimeInterval:time];;
                
                NSString *content = timeAndContent[1];
                lrcModel.lrcStr = content;
            } else if (timeAndContent.count == 1) {
                NSString *time = timeAndContent[0];
                lrcModel.beginTime = [TimeTool getTimeInterval:time];
                lrcModel.lrcStr = nil;
            }
        }
    }];
    // 修改模型的结束时间
    NSInteger count = lrcMs.count;
    [lrcMs enumerateObjectsUsingBlock:^(LrcModel *lrcModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != count - 1) {
            lrcMs[idx].endTime = lrcMs[idx + 1].beginTime;
        }
    }];
    return lrcMs;
}

+ (void)getRow:(NSTimeInterval)currentTime
       andLrcs:(NSArray<LrcModel *> *)lrcMs
    completion:(void (^)(NSInteger row, LrcModel *lrcModel))completion{
    
    __block NSInteger row = 0;
    __block LrcModel *lrcModel = [[LrcModel alloc] init];
    
    [lrcMs enumerateObjectsUsingBlock:^(LrcModel *lrc, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (currentTime >= lrc.beginTime && currentTime <= lrc.endTime) {
            
            row = idx;
            lrcModel = lrc;
            *stop = YES;
        }
    }];
    completion(row, lrcModel);
    
}

@end
