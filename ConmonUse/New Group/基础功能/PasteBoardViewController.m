//
//  PasteBoardViewController.m
//  ConmonUse
//
//  Created by  on 2018/9/16.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "PasteBoardViewController.h"

@interface PasteBoardViewController ()

@end

@implementation PasteBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
     + (UIPasteboard *)generalPasteboard;系统级别的剪切板在整个设备中共享，
     即是应用程序被删掉，其向系统级的剪切板中写入的数据依然在
     
     
     + (nullable UIPasteboard *)pasteboardWithName:(NSString *)pasteboardName create:(BOOL)create;
     自定义的剪切板通过一个特定的名称字符串进行创建，
     它在应用程序内或者同一开发者开发的其他应用程序中可以进行数据共享。
     举个例子：比如你开发了多款应用，用户全部下载了，在A应用中用户拷贝了一些数据（为了数据安全，
     不用系统级别的Pasteboard），在打开B应用时就会自动识别，提高用户体验。
     */
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    
    NSArray * ary = pasteboard.items;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
