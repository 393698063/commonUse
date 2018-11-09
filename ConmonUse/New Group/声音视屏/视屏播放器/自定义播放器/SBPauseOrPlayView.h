//
//  SBPauseOrPlayView.h
//  ConmonUse
//
//  Created by Qiao,Gang(RM) on 2018/10/22.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN
@class SBPauseOrPlayView;
@protocol SBPauseOrPlayViewDelegate <NSObject>
@required
/**
 暂停和播放视图和状态
 
 @param pauseOrPlayView 暂停或者播放视图
 @param state 返回状态
 */
-(void)pauseOrPlayView:(SBPauseOrPlayView *)pauseOrPlayView withState:(BOOL)state;
@end

@interface SBPauseOrPlayView : UIView
@property (nonatomic,strong) UIButton *imageBtn;
@property (nonatomic,weak) id<SBPauseOrPlayViewDelegate> delegate;
@property (nonatomic,assign,readonly) BOOL state;
@end

NS_ASSUME_NONNULL_END
