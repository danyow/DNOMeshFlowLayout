//
//  DNOMeshFlowLayout.m
//  DNOMeshFlowLayoutDemo
//
//  Created by Danyow on 2016/11/20.
//  Copyright © 2016年 Danyow.Ed. All rights reserved.
//

#import "DNOMeshFlowLayout.h"
#import <objc/runtime.h>

@interface DNOMeshFlowLayout ()

@property (nonatomic, assign) IBInspectable BOOL flexibleWidth;
@property (nonatomic, assign) IBInspectable BOOL flexibleHeight;

@property (nonatomic, strong) NSMutableArray *attributes;

@property (nonatomic, strong) NSArray <NSNumber*>*columnWidthArray;
@property (nonatomic, strong) NSArray <NSNumber*>*rowHeightArray;
@property (nonatomic, assign) CGFloat sumColumnWidth;
@property (nonatomic, assign) CGFloat sumRowHeight;

@property (nonatomic, strong) NSMutableArray *rowIndexPaths;

@end

@implementation DNOMeshFlowLayout


+ (UICollectionView *)meshCollectionViewWithDataSource:(id <DNOMeshFlowLayoutDataSource, DNOMeshFlowLayoutDelegate>)dataSource FlexibleWidth:(BOOL)flexibleWidth flexibleHeight:(BOOL)flexibleHeight
{
    DNOMeshFlowLayout *flowLayout = [DNOMeshFlowLayout flowLayoutWithFlexibleWidth:flexibleWidth flexibleHeight:flexibleHeight];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.dataSource = flowLayout;
    collectionView.delegate   = flowLayout;
    flowLayout.dataSource     = dataSource;
    flowLayout.delegate       = dataSource;
    return collectionView;
}

+ (instancetype)flowLayoutWithFlexibleWidth:(BOOL)flexibleWidth flexibleHeight:(BOOL)flexibleHeight
{
    DNOMeshFlowLayout *flowLayout = [[DNOMeshFlowLayout alloc] init];
    flowLayout.flexibleWidth           = flexibleWidth;
    flowLayout.flexibleHeight          = flexibleHeight;
    flowLayout.minimumLineSpacing      = 0;
    flowLayout.minimumInteritemSpacing = 0;
    return flowLayout;
}

- (void)prepareLayout
{
    [self.attributes removeAllObjects];
    [super prepareLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    CGFloat collectionViewWidth  = self.collectionView.frame.size.width;
    CGFloat collectionViewHeight = self.collectionView.frame.size.height;
    __block CGRect preRow  = CGRectZero;
    __block CGFloat y      = 0;
    __block CGFloat height = 0;
    [self.rowHeightArray enumerateObjectsUsingBlock:^(NSNumber *heightNumber, NSUInteger row, BOOL *stop) {
        y      = CGRectGetMaxY(preRow);
        height = heightNumber.doubleValue / (self.flexibleHeight ? : self.sumRowHeight / collectionViewHeight);
        __block CGRect preColumn = CGRectZero;
        __block CGFloat x        = 0;
        __block CGFloat width    = 0;
        [self.columnWidthArray enumerateObjectsUsingBlock:^(NSNumber *widthNumber, NSUInteger column, BOOL *stop) {
            x     = CGRectGetMaxX(preColumn);
            width = widthNumber.doubleValue / (self.flexibleWidth ? : self.sumColumnWidth / collectionViewWidth);
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row * self.columnWidthArray.count + column inSection:0];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
            if ([self.dataSource respondsToSelector:@selector(collectionView:cellEdgeInsetsForItemAtRow:column:indexPath:)]) {
                edgeInsets = [self.dataSource collectionView:self.collectionView cellEdgeInsetsForItemAtRow:row column:column indexPath:indexPath];
            }
            
            CGFloat top    = edgeInsets.top / (self.flexibleHeight ? : self.sumRowHeight / collectionViewHeight);
            CGFloat left   = edgeInsets.left / (self.flexibleWidth ? : self.sumColumnWidth / collectionViewWidth);
            CGFloat right  = edgeInsets.right / (self.flexibleWidth ? : self.sumColumnWidth / collectionViewWidth);
            CGFloat bottom = edgeInsets.bottom / (self.flexibleHeight ? : self.sumRowHeight / collectionViewHeight);
            
            
            CGRect frame = CGRectMake(x, y, width, height);
            frame.origin.x    -= left;
            frame.origin.y    -= top;
            frame.size.width  += (left + right);
            frame.size.height += (top + bottom);
            
            attributes.frame = frame;
            [self.attributes addObject:attributes];
            preColumn = CGRectMake(x, 0, width, 0);
        }];
        preRow = CGRectMake(0, y, 0, height);
    }];
}


- (CGSize)collectionViewContentSize
{
    [super collectionViewContentSize];
    if (!self.flexibleWidth && !self.flexibleHeight) {
        return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    }
    if (!self.flexibleWidth && self.flexibleHeight) {
        return CGSizeMake(self.collectionView.frame.size.width, self.sumRowHeight);
    }
    if (self.flexibleWidth && !self.flexibleHeight) {
        return CGSizeMake(self.sumColumnWidth, self.collectionView.frame.size.height);
    }
    if (self.flexibleWidth && self.flexibleHeight) {
        return CGSizeMake(self.sumColumnWidth, self.sumRowHeight);
    }
    return CGSizeZero;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attributes;
}

#pragma mark -
#pragma mark  UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(rowHeightArrayOfCollectionView:)]) {
        self.rowHeightArray = [self.dataSource rowHeightArrayOfCollectionView:self.collectionView];
        self.sumRowHeight   = [[self.rowHeightArray valueForKeyPath:@"@sum.doubleValue"] doubleValue];
    }
    if ([self.dataSource respondsToSelector:@selector(columnWidthArrayOfCollectionView:)]) {
        self.columnWidthArray = [self.dataSource columnWidthArrayOfCollectionView:self.collectionView];
        self.sumColumnWidth   = [[self.columnWidthArray valueForKeyPath:@"@sum.doubleValue"] doubleValue];
    }
    self.collectionView.fetch = self;
    return self.rowHeightArray.count * self.columnWidthArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.item / self.columnWidthArray.count;
    NSInteger column = indexPath.item % self.columnWidthArray.count;
    UICollectionViewCell *cell;
    if ([self.dataSource respondsToSelector:@selector(collectionView:cellForItemAtRow:column:indexPath:)]) {
        cell = [self.dataSource collectionView:collectionView cellForItemAtRow:row column:column indexPath:indexPath];
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    cell.selectedBackgroundView = view;
    return cell;
}

#pragma mark -
#pragma mark  UICollectionViewDelegate

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger row = indexPath.item / self.columnWidthArray.count;
//    [collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSIndexPath *index = [collectionView indexPathForCell:obj];
//        if (row == index.item / self.columnWidthArray.count) {
//            obj.selected = YES;
//        }
//    }];
//    return YES;
//}

//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger row = indexPath.item / self.columnWidthArray.count;
//    [collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSIndexPath *index = [collectionView indexPathForCell:obj];
//        if (row == index.item / self.columnWidthArray.count) {
//            obj.selected = YES;
//        }
//    }];
//    NSLog(@"%s", __FUNCTION__);
//}

//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger row = indexPath.item / self.columnWidthArray.count;
//    [collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSIndexPath *index = [collectionView indexPathForCell:obj];
//        if (row == index.item / self.columnWidthArray.count) {
//            obj.selected = NO;
//        }
//    }];
//    NSLog(@"%s", __FUNCTION__);
//}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.item / self.columnWidthArray.count;
    NSInteger column = indexPath.item % self.columnWidthArray.count;
    NSInteger columnCount = self.columnWidthArray.count;
    self.rowIndexPaths = [[NSMutableArray alloc] initWithCapacity:columnCount];
    [self.rowIndexPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
    NSInteger firstIndex = row * columnCount;
    NSInteger lastIndex  = (row + 1) * columnCount;
    for (NSInteger i = firstIndex; i < lastIndex; ++i) {
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.rowIndexPaths addObject:rowIndexPath];
        [collectionView selectItemAtIndexPath:rowIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtRow:column:indexPath:)]) {
        [self.delegate collectionView:collectionView didSelectItemAtRow:row column:column indexPath:indexPath];
    } else {
        [collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:lastIndex - 1 inSection:0] animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.item / self.columnWidthArray.count;
    NSInteger column = indexPath.item % self.columnWidthArray.count;
    NSInteger columnCount = self.columnWidthArray.count;
    self.rowIndexPaths = [[NSMutableArray alloc] initWithCapacity:columnCount];
    [self.rowIndexPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
    NSInteger firstIndex = row * columnCount;
    NSInteger lastIndex  = (row + 1) * columnCount;
    for (NSInteger i = firstIndex; i < lastIndex; ++i) {
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.rowIndexPaths addObject:rowIndexPath];
        [collectionView deselectItemAtIndexPath:rowIndexPath animated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionView:didDeselectItemAtRow:column:indexPath:)]) {
        [self.delegate collectionView:collectionView didDeselectItemAtRow:row column:column indexPath:indexPath];
    }
}



#pragma mark -
#pragma mark  UICollectionViewFetch

- (UICollectionViewCell *)cellForItemAtRow:(NSInteger)row column:(NSInteger)column
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row * self.columnWidthArray.count + column inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}


#pragma mark -
#pragma mark  lazy load

- (NSMutableArray *)attributes
{
    if (!_attributes) {
        _attributes = [[NSMutableArray alloc] initWithCapacity:self.rowHeightArray.count * self.columnWidthArray.count];
    }
    return _attributes;
}

@end

//////////////////////////////////////////////////
@implementation UICollectionView (DNOMeshFetch)

/** 强行增加一个Fetch属性 根据row和column找到对应的cell */

static void *fetchKey = &fetchKey;

- (void)setFetch:(id<UICollectionViewFetch>)fetch
{
    objc_setAssociatedObject(self, &fetchKey, fetch, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UICollectionViewFetch>)fetch
{
    return objc_getAssociatedObject(self, &fetchKey);
}

- (UICollectionViewCell *)cellForItemAtRow:(NSInteger)row column:(NSInteger)column
{
    if ([self.fetch respondsToSelector:@selector(cellForItemAtRow:column:)]) {
        return [self.fetch cellForItemAtRow:row column:column];
    } else {
        return nil;
    }
}
@end
//////////////////////////////////////////////////
