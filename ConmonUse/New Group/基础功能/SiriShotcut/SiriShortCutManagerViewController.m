//
//  SiriShortCutManagerViewController.m
//  ConmonUse
//
//    on 2018/10/14.
//  Copyright © 2018年 jorgon. All rights reserved.
//

/*
 本文介绍 Siri ShortCuts 的应用之一，可实现的功能是：
 1、通过自定义 siri 短语打开 app , 并完成你想要完成的操作。
 2、根据对用户行为的记录，让系统智能预测用户行为，并给出提示。
 3、app 内引导用户添加或者修改语音指令
 */

#import "SiriShortCutManagerViewController.h"
#import <Intents/Intents.h>
#import <IntentsUI/IntentsUI.h>
#import "IntentIntent.h"
#import "SecondIntentIntent.h"



API_AVAILABLE(ios(12.0))
@interface SiriShortCutManagerViewController ()
<INUIAddVoiceShortcutButtonDelegate,
INUIEditVoiceShortcutViewControllerDelegate,
INUIAddVoiceShortcutViewControllerDelegate,
UITableViewDelegate,
UITableViewDataSource>
//@property (nonatomic, strong) INUIEditVoiceShortcutViewController * shortcutVC;
@property (nonatomic, strong) IntentIntent * intent;
@property (nonatomic, strong) SecondIntentIntent * secondIntent;
@property (nonatomic, strong) INUIAddVoiceShortcutButton * shortcutButton;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataAry;
@end

@implementation SiriShortCutManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
//[INVoiceShortcutCenter.sharedCenter setShortcutSuggestions:@[]];
    [INVoiceShortcutCenter.sharedCenter getAllVoiceShortcutsWithCompletion:^(NSArray<INVoiceShortcut *> * _Nullable voiceShortcuts, NSError * _Nullable error) {
        NSLog(@"%@",voiceShortcuts);
        [voiceShortcuts enumerateObjectsUsingBlock:^(INVoiceShortcut * _Nonnull voiceShortcut, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.dataAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                INtentModel * model = (INtentModel *)obj;
                if ([model.name isEqualToString:NSStringFromClass(voiceShortcut.shortcut.intent.class)]) {
                    model.isAdd = YES;
                    model.voiceShortcut = voiceShortcut;
                    * stop = YES;
                }
            }];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];

//
//    if (@available(iOS 12.0, *)) {
//        _shortcutButton = [[INUIAddVoiceShortcutButton alloc] initWithStyle:INUIAddVoiceShortcutButtonStyleWhiteOutline];
//        _shortcutButton.shortcut = [[INShortcut alloc] initWithIntent:self.secondIntent];
////        _shortcutButton.translatesAutoresizingMaskIntoConstraints = false;
//        _shortcutButton.delegate = self;
////        _shortcutButton.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
//        _shortcutButton.frame = CGRectMake(100, 100, 200, 100);
//        [self.view addSubview:_shortcutButton];
//    }
    
}

- (IntentIntent *)intent API_AVAILABLE(ios(12.0)){
    if (!_intent) {
        _intent = [[IntentIntent alloc] init];
        _intent.suggestedInvocationPhrase = @"我的第一个语音";   //在Siri语音设置时显示的建议设置唤起文字
    }
    return _intent;
}

- (SecondIntentIntent *)secondIntent  API_AVAILABLE(ios(12.0)){
    if (!_secondIntent) {
        _secondIntent = [[SecondIntentIntent alloc] init];
        _secondIntent.suggestedInvocationPhrase = @"我的经常用列表";
    }
    return _secondIntent;
}


- (NSMutableArray *)dataAry {
    if (!_dataAry) {
        _dataAry = [NSMutableArray arrayWithCapacity:1];
        
        INtentModel * model1 = [[INtentModel alloc] init];
        model1.name = NSStringFromClass(self.intent.class);
        
        INtentModel * model2 = [[INtentModel alloc] init];
        model2.name = NSStringFromClass(self.secondIntent.class);
        
        [_dataAry addObject:model1];
        [_dataAry addObject:model2];
    }
    return _dataAry;
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"testSiri"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"testSiri"];
    }
    INtentModel * model = [self.dataAry objectAtIndex:indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.isAdd?@"已经添加去修改":@"去添加";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    INtentModel * model = self.dataAry[indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            if (model.isAdd) {
                INShortcut * shortcut = [[INShortcut alloc] initWithIntent:self.intent];
                INUIEditVoiceShortcutViewController * vc = [[INUIEditVoiceShortcutViewController alloc] initWithVoiceShortcut:model.voiceShortcut];
                vc.delegate = self;
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                INShortcut * shortcut = [[INShortcut alloc] initWithIntent:self.intent];
                INUIAddVoiceShortcutViewController * vc = [[INUIAddVoiceShortcutViewController alloc] initWithShortcut:shortcut];
                vc.delegate = self;
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
            break;
        case 1:
        {
            if (model.isAdd) {
                INUIEditVoiceShortcutViewController * vc = [[INUIEditVoiceShortcutViewController alloc] initWithVoiceShortcut:model.voiceShortcut];
                vc.delegate = self;
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                INShortcut * shortcut = [[INShortcut alloc] initWithIntent:self.secondIntent];
                INUIAddVoiceShortcutViewController * vc = [[INUIAddVoiceShortcutViewController alloc] initWithShortcut:shortcut];
                vc.delegate = self;
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - INUIEditVoiceShortcutViewControllerDelegate
/*!
 @abstract Called if the user updates the voice shortcut, with either the successfully-updated voice shortcut, or an error.
 @discussion Your implementation of this method should dismiss the view controller.
 */
- (void)editVoiceShortcutViewController:(INUIEditVoiceShortcutViewController *)controller
                 didUpdateVoiceShortcut:(nullable INVoiceShortcut *)voiceShortcut
                                  error:(nullable NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

/*!
 @abstract Called if the user deletes the voice shortcut.
 @discussion Your implementation of this method should dismiss the view controller.
 */
- (void)editVoiceShortcutViewController:(INUIEditVoiceShortcutViewController *)controller
   didDeleteVoiceShortcutWithIdentifier:(NSUUID *)deletedVoiceShortcutIdentifier{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [INVoiceShortcutCenter.sharedCenter getVoiceShortcutWithIdentifier:deletedVoiceShortcutIdentifier
                                                            completion:^(INVoiceShortcut * _Nullable voiceShortcut, NSError * _Nullable error) {
        [self.dataAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            INtentModel * model = (INtentModel *)obj;
            if ([model.name isEqualToString:NSStringFromClass(voiceShortcut.shortcut.intent.class)]) {
                model.isAdd = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                * stop = YES;
            }
        }];
    }];
    
    
}

/*!
 @abstract Called if the user cancelled; no changes were made to the voice shortcut.
 @discussion Your implementation of this method should dismiss the view controller.
 */
- (void)editVoiceShortcutViewControllerDidCancel:(INUIEditVoiceShortcutViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - INUIAddVoiceShortcutViewControllerDelegate
/*!
 @abstract Called after the user finishes the setup flow for the voice shortcut, with either the successfully-added voice shortcut, or an error.
 @discussion Your implementation of this method should dismiss the view controller.
 */
- (void)addVoiceShortcutViewController:(INUIAddVoiceShortcutViewController *)controller
            didFinishWithVoiceShortcut:(nullable INVoiceShortcut *)voiceShortcut
                                 error:(nullable NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

/*!
 @abstract Called if the user cancels the setup flow; the voice shortcut was not added.
 @discussion Your implementation of this method should dismiss the view controller.
 */
- (void)addVoiceShortcutViewControllerDidCancel:(INUIAddVoiceShortcutViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - INUIAddVoiceShortcutButtonDelegate
- (void)presentAddVoiceShortcutViewController:(nonnull INUIAddVoiceShortcutViewController *)addVoiceShortcutViewController forAddVoiceShortcutButton:(nonnull INUIAddVoiceShortcutButton *)addVoiceShortcutButton {
    addVoiceShortcutViewController.delegate = self;
    [self presentViewController:addVoiceShortcutViewController animated:YES completion:nil];
}

- (void)presentEditVoiceShortcutViewController:(nonnull INUIEditVoiceShortcutViewController *)editVoiceShortcutViewController
                     forAddVoiceShortcutButton:(nonnull INUIAddVoiceShortcutButton *)addVoiceShortcutButton {
    editVoiceShortcutViewController.delegate = self;
    [self presentViewController:editVoiceShortcutViewController animated:YES completion:nil];
}

@end




@implementation INtentModel


@end
