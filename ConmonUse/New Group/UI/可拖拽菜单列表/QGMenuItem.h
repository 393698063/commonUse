//
//  QGMenuItem.h
//  ConmonUse
//
//  Created by jorgon on 16/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QGMenuItem : UICollectionViewCell
//标题
@property (nonatomic, copy) NSString *title;

//是否正在移动状态
@property (nonatomic, assign) BOOL isMoving;

//是否被固定
@property (nonatomic, assign) BOOL isFixed;
@end
