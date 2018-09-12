//
//  QRCode.h
//  ConmonUse
//
//  Created by jorgon on 03/09/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Singleton.h"

@interface QRCode : NSObject
singleton_h(Code)
+ (UIImage *)generateQRcode:(NSString *)message;
- (void)ReadingQRCode:(UIViewController *)controller;
- (void)stopRunning;
@end
