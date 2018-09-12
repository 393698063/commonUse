//
//  GraphicViewController.m
//  ConmonUse
//
//  Created by jorgon on 03/09/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "GraphicViewController.h"
#import "QRCode.h"

@interface GraphicViewController ()

@end

@implementation GraphicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 100, 100, 100)];
    imageView.image = [QRCode generateQRcode:@"乔钢"];
    [self.view addSubview:imageView];
    
    [[QRCode sharedCode] ReadingQRCode:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[QRCode sharedCode] stopRunning];
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
