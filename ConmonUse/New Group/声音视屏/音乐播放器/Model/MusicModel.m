//
//  MusicModel.m
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "MusicModel.h"

@implementation MusicModel
- (void)setSingerIcon:(NSString *)singerIcon {
    _singerIcon = Resources([@"Images" stringByAppendingPathComponent:singerIcon]);
}

- (void)setLrcname:(NSString *)lrcname {
    _lrcname = Resources([@"Lrcs" stringByAppendingPathComponent:lrcname]);
}

- (void)setFilename:(NSString *)filename {
    _filename = Resources([@"MP3s" stringByAppendingPathComponent:filename]);
}

- (void)setIcon:(NSString *)icon {
    _icon = Resources([@"Images" stringByAppendingPathComponent:icon]);
}
@end
