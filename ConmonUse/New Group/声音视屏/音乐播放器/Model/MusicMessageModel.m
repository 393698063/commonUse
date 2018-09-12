//
//  MusicMessageModel.m
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "MusicMessageModel.h"
#import "TimeTool.h"

@implementation MusicMessageModel
- (NSString *)costTimeFormat{
    
    return [TimeTool getFormatTime:self.costTime];
}

- (NSString *)totalTimeFormat{
    
    return [TimeTool getFormatTime:self.totalTime];
}
@end
