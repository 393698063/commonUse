//
//  ScrolloffsetViewController.m
//  ConmonUse
//
//  Created by jorgon on 2018/11/13.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "ScrolloffsetViewController.h"
#import <YYCategories.h>

@interface ScrolloffsetViewController ()
@property (nonatomic, strong) UIScrollView * scrollView;
@end

@implementation ScrolloffsetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString * path = [cachePath stringByAppendingPathComponent:@"test.tex"];
    NSDictionary * dict = @{@"a": @"b"};
    NSError *parseError = nil;
    if([NSJSONSerialization isValidJSONObject:dict]) {//判断是否是合格json对象
        NSData  *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
        if(!parseError) {
            //可以自己创建文件夹
            if ([data writeToFile:path atomically:YES]) {
                NSLog(@"cacheWtireItems scucess");
            }
        }
    }
    
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.width, self.scrollView.height);
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.width, self.scrollView.height)];
    v.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:v];
}
#warning 测试scrollView的contentsize
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint offset = self.scrollView.contentOffset;
    CGFloat distance = self.view.height * 0.2;
    [UIView animateWithDuration:0.58 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake(offset.x, offset.y + distance);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentOffset = CGPointMake(offset.x, offset.y + distance);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.58 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.scrollView.contentOffset = CGPointMake(offset.x, offset.y);
            } completion:^(BOOL finished) {
                //                [weakSelf hideAnimation];
            }];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)textFieldDidChange {
    //    NSString *toBeString = textField.text;
    //
    //    int kmaxLength =10;//设置最大输入值
    //
    //    UITextInputMode *currentInputMode = textField.textInputMode;
    //    NSString *lang = [currentInputMode primaryLanguage]; // 键盘输入模式
    //
    //    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
    //        UITextRange *selectedRange = [textField markedTextRange];
    //        //获取高亮部分
    //        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    //        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    //        if (!position) {
    //            if (toBeString.length > kmaxLength) {
    //                textField.text = [toBeString substringToIndex:kmaxLength];
    //            }
    //            self.videoTitleLengthLabel.text = [NSString stringWithFormat:@"%lu/10",textField.text.length];
    //        }
    //        // 有高亮选择的字符串，则暂不对文字进行统计和限制
    //        else{
    //
    //        }
    //    }
    //    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    //    else{
    //        if (toBeString.length > kmaxLength) {
    //            textField.text = [toBeString substringToIndex:kmaxLength];
    //        }
    //        self.videoTitleLengthLabel.text = [NSString stringWithFormat:@"%lu/10",textField.text.length];
    //    }
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
