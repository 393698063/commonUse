//
//  QGLocalPushViewController.m
//  ConmonUse
//
//  Created by qiaogang02 on 2019/12/7.
//  Copyright © 2019 jorgon. All rights reserved.
//

#import "QGLocalPushViewController.h"

#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UNNotificationSettings.h>
#import "AppDelegate.h"
#import "QGLaunchMethodSetion.h"
QG_FUNCTIONS_EXPORT_BEGIN(LEVEL_A)
[QGLocalPushViewController registLocalPush];

QG_FUNCTIONS_EXPORT_END(LEVEL_A)


@interface QGLocalPushViewController ()

@end

@implementation QGLocalPushViewController

+ (void)registLocalPush {
    if (@available(iOS 10.0, *)) { // iOS10 以上
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
    } else {// iOS8.0 以上
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
                                                UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound
                                                                                 categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
     if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            // 标题
            content.title = @"测试标题";
            content.subtitle = @"测试通知副标题";
            // 内容
            content.body = @"测试通知的具体内容";
            // 声音
           // 默认声音
         //    content.sound = [UNNotificationSound defaultSound];
         // 添加自定义声音
           content.sound = [UNNotificationSound soundNamed:@"Alert_ActivityGoalAttained_Salient_Haptic.caf"];
            // 角标 （我这里测试的角标无效，暂时没找到原因）
            content.badge = @1;
            // 多少秒后发送,可以将固定的日期转化为时间
            NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:10] timeIntervalSinceNow];
    //        NSTimeInterval time = 10;
            // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
            
            /*
            //如果想重复可以使用这个,按日期
            // 周一早上 8：00 上班
            NSDateComponents *components = [[NSDateComponents alloc] init];
            // 注意，weekday默认是从周日开始
            components.weekday = 2;
            components.hour = 8;
            UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
            */
            // 添加通知的标识符，可以用于移除，更新等操作
            NSString *identifier = @"noticeId";
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
            
            [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
                NSLog(@"成功添加推送");
            }];
        }else {
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            // 发出推送的日期
            notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
            // 推送的内容
            notif.alertBody = @"你已经10秒没出现了";
            // 可以添加特定信息
            notif.userInfo = @{@"noticeId":@"00001"};
            // 角标
            notif.applicationIconBadgeNumber = 1;
            // 提示音
            notif.soundName = UILocalNotificationDefaultSoundName;
            // 每周循环提醒
            notif.repeatInterval = NSCalendarUnitWeekOfYear;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
