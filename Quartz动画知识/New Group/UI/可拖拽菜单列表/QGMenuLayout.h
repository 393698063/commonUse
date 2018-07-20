//
//  QGMenuLayout.h
//  Quartz动画知识
//
//  Created by jorgon on 18/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QGMenuLayoutDelegate <NSObject>
- (BOOL)canMoveCollectionItemAtindexPath:(NSIndexPath*)indexPath;
- (void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (CGFloat)headerHeightAtSection:(NSInteger)section;
@end

@interface QGMenuLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, weak) id<QGMenuLayoutDelegate> delegate;
@end
