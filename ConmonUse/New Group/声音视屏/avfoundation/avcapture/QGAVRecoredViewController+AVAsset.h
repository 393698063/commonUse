//
//  QGAVRecoredViewController+AVAsset.h
//  ConmonUse
//
//  Created by jorgon on 2019/6/10.
//  Copyright © 2019年 jorgon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, FMRecordState) {
    FMRecordStateInit = 0,
    FMRecordStatePrepareRecording,
    FMRecordStateRecording,
    FMRecordStateFinish,
    FMRecordStateFail,
};
@interface QGAVRecoredViewController_AVAsset : UIViewController

@end

NS_ASSUME_NONNULL_END
