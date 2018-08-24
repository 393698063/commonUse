//
//  QGMenuView.h
//  ConmonUse
//
//  Created by jorgon on 16/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QGMenuView : UIView
@property (nonatomic, strong) NSMutableArray *inUseTitles;

@property (nonatomic,strong) NSMutableArray *unUseTitles;
-(void)reloadData;
@end
