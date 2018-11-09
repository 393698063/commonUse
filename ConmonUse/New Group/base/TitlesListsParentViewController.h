//
//  LMJTitlesListsParentViewController.h
//  GoMeYWLC
//
//  Created by NJHu on 2017/5/15.
//  Copyright © 2017年 NJHu. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <YYCategories.h>

@protocol TitlesListsParentViewControllerDataSource <NSObject>


@required
// 必须添加子控制器并且设置标题
- (void)addChildViewControllers;


@optional
/** 正常情况下的颜色, 默认黄色; */
- (UIColor *)titleBtnNormalColor;

/** 选中的颜色, 默认 亮灰色; */
- (UIColor *)titleBtnSelectedColor;

/** 标题的字体, 默认14 */
- (UIFont *)titleBtnFont;


/**
 第一次进来的时候展示哪个页面
 */
- (NSInteger)firstShowIndex;

@end

// 子类控制器实现,
@protocol TitlesListsParentViewControllerDelegate <NSObject>

@optional
// 当子类控制器显示的时候通知
- (void)listsParentViewController:(UIViewController *)listsParentViewController childViewController:(UIViewController *)childViewController childViewControllerViewWillShow:(UIView *)childViewControllerView;

@end


@interface TitlesListsParentViewController : UIViewController<TitlesListsParentViewControllerDataSource>

/** 所有的标题按钮 */
@property (strong, nonatomic) NSMutableArray<UIButton *> *titleBtns;

/** <#digest#> */
@property (weak, nonatomic) UIScrollView *contentScrollView;

/** <#digest#> */
@property (weak, nonatomic) UIView *titlesView;

/** <#digest#> */
@property (weak, nonatomic) UIView *indicatorView;

/** <#digest#> */
@property (weak, nonatomic) UIViewController *showingOnWindowController;


- (void)selectTitle:(UIButton *)btn NS_REQUIRES_SUPER;


@end
