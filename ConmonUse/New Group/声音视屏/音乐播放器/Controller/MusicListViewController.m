//
//  MusicListViewController.m
//  ConmonUse
//
//  Created by jorgon on 25/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "MusicListViewController.h"
#import <Masonry.h>
#import "MusicOperationTool.h"
#import "MusicModel.h"
#import "MusicPlayViewController.h"

@interface MusicListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * tableview;

@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"音乐播放器";
    UITableView * tablview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tablview.delegate = self;
    tablview.dataSource = self;
    [self.view addSubview:tablview];
    self.tableview = tablview;
    
}
- (void)updateViewConstraints{
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10,10));
    }];
    [super updateViewConstraints];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [MusicOperationTool shareInstance].musicMList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tt"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    }
    MusicModel * music = [MusicOperationTool shareInstance].musicMList[indexPath.row];
    cell.textLabel.text = music.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    MusicPlayViewController * player = [[MusicPlayViewController alloc] init];
    [MusicOperationTool.shareInstance playMusic:MusicOperationTool.shareInstance.musicMList[indexPath.row]];
    [self.navigationController pushViewController:player animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"%s",__func__);
    [[MusicOperationTool shareInstance] stopCurrentMusic];
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
