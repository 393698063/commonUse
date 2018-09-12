//
//  CALayer+LayerPause.h
//  ConmonUse
//
//  Created by jorgon on 27/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (LayerPause)
- (void)pauseLayer:(CALayer*)layer;
- (void)resumeLayer:(CALayer*) layer;
@end
