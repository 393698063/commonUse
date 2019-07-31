//
//  SiriShortCutManagerViewController.h
//  ConmonUse
//
//  Created by jorgon(RM) on 2018/10/14.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Intents/Intents.h>

@interface SiriShortCutManagerViewController : UIViewController

@end

@interface INtentModel : NSObject
@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) BOOL isAdd;
@property (nonatomic, strong) INVoiceShortcut * voiceShortcut;
@end
