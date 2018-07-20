//
//  QGMenuView.m
//  Quartz动画知识
//
//  Created by jorgon on 16/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//



#import "QGMenuView.h"
#import "QGMenuItem.h"
#import "QGMenuHeader.h"
#import "QGMenuLayout.h"

//菜单列数
static NSInteger ColumnNumber = 4;
//横向和纵向的间距
static CGFloat CellInterSpace = 15.0f;//间隙
static CGFloat CellLineSpace = 10.0f;//行间距

@interface QGMenuView ()<UICollectionViewDelegate,UICollectionViewDataSource,QGMenuLayoutDelegate>
{
    UICollectionView * _collectionView;
    QGMenuItem * _dragingItem;
    //正在拖拽的indexpath
    NSIndexPath *_dragingIndexPath;
    //目标位置
    NSIndexPath *_targetIndexPath;
}
@end

@implementation QGMenuView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self prepareUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self prepareUI];
    }
    
    return self;
}

- (void)prepareUI{
    
    QGMenuLayout * layout = [[QGMenuLayout alloc] init];;
    layout.columnNumber = ColumnNumber;
    CGFloat cellWidth = (self.bounds.size.width - (ColumnNumber + 1) * CellInterSpace) / ColumnNumber;
    layout.delegate = self;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth/2.0f);
    // 设置其边界
    layout.sectionInset = UIEdgeInsetsMake(CellLineSpace, CellInterSpace, CellLineSpace, CellInterSpace);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = CellInterSpace;
    layout.headerReferenceSize = CGSizeMake(self.bounds.size.width, 40);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[QGMenuItem class] forCellWithReuseIdentifier:NSStringFromClass([QGMenuItem class])];
    [_collectionView registerClass:[QGMenuHeader class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"header"];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
}
#pragma mark - CollectionViewDelegate&Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return section == 0 ? _inUseTitles.count : _unUseTitles.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath{
    QGMenuHeader * headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                    withReuseIdentifier:@"header"
                                                                           forIndexPath:indexPath];
    if (indexPath.section == 0) {
        headerView.title = @"已选频道";
        headerView.subTitle = @"按住拖动调整排序";
    }else{
        headerView.title = @"推荐频道";
        headerView.subTitle = @"";
    }
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QGMenuItem * item = [_collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QGMenuItem class])
                                                                   forIndexPath:indexPath];
    
    item.title = indexPath.section == 0 ? _inUseTitles[indexPath.row] : _unUseTitles[indexPath.row];
    item.isFixed = indexPath.section == 0 && indexPath.row == 0;
    
    return item;
}

-(void)reloadData
{
    [_collectionView reloadData];
}

#pragma mark - QGMenulayoutDelegate

- (BOOL)canMoveCollectionItemAtindexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? true : false;
}

- (void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    id obj = [self.inUseTitles objectAtIndex:fromIndexPath.row];
    [self.inUseTitles removeObjectAtIndex:fromIndexPath.row];
    [self.inUseTitles insertObject:obj atIndex:toIndexPath.row];
}

- (CGFloat)headerHeightAtSection:(NSInteger)section{
    return 40;
}




@end
