//
//  QGMenuController.h
//  ConmonUse
//
//  Created by jorgon on 17/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ChannelBlock)(NSArray *inUseTitles,NSArray *unUseTitles);
@interface QGMenuController : UIViewController
+ (QGMenuController *)shareController;
-(void)showChannelViewWithInUseTitles:(NSArray*)inUseTitles unUseTitles:(NSArray*)unUseTitles finish:(ChannelBlock)block;
@end
