//
//  AppDelegate.m
//  ConmonUse
//
//  Created by jorgon on 06/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "SignalHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //1. 抓取crash 方法，
//    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    //2 通过信号
    [SignalHandler RegisterSignalHandler];
    return YES;
}



- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    NSLog(@"%@",userActivity.activityType);
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        // 通用链接
        NSURL * url = userActivity.webpageURL;
        NSLog(@"外部打开的URL：%@",url.absoluteString);
    } else if ([userActivity.activityType isEqualToString:@"IntentIntent"]) {
        NSLog(@"请处理intent");
    } else if ([userActivity.activityType isEqualToString:@"SecondIntentIntent"]) {
        NSLog(@"请处理secondintent");
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}




- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark    收集异常，存储到本地，下次用户打开程序时上传给我们
void UncaughtExceptionHandler(NSException *exception) {
    /**
     *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString * dateStr = [formatter stringFromDate:[NSDate date]];
    
//    NSString * userID   =   [NUD objectForKey:USERID];
//    NSString * userName =   [NUD objectForKey:USERNAME];
    
    NSString * iOS_Version = [[UIDevice currentDevice] systemVersion];
    NSString * PhoneSize    =   NSStringFromCGSize([[UIScreen mainScreen] bounds].size);
    
    NSString * App_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    NSString * iPhoneType = [RSToolNSObject getiPhoneType];
    
//    NSString *content = [NSString stringWithFormat:@"%@<br>\niOS_Version : %@----PhoneSize : %@<br>\n----iPhoneType: %@<br>\nApp_Version : %@<br>\nuserID : %@<br>\nuserName : %@<br>\nname:%@<br>\nreason:\n%@<br>\ncallStackSymbols:\n%@",dateStr,iOS_Version,PhoneSize,iPhoneType,App_Version,userID,userName,name,reason,[callStack componentsJoinedByString:@"\n"]];
    
#if DEBUG
//    NSDictionary * dictionary   =   @{@"content":content,
//                                      @"isDebug":@(1),
//                                      @"packageName":@"com.thinkjoy.NetworkTaxiDriver"};
#else
//    NSDictionary * dictionary   =   @{@"content":content,
//                                      @"isDebug":@(0),
//                                      @"packageName":@"com.thinkjoy.NetworkTaxiDriver"};
#endif
    
//    [NUD setObject:dictionary forKey:Sandbox_appErrorInfo];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Quartz____"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
