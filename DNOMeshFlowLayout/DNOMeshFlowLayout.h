//
//  DNOMeshFlowLayout.h
//  DNOMeshFlowLayoutDemo
//
//  Created by Danyow on 2016/11/20.
//  Copyright © 2016年 Danyow.Ed. All rights reserved.
//

#import <UIKit/UIKit.h>

//////////////////////////////////////////////////
#pragma mark -
#pragma mark  Mesh Fetch
@class DNOMeshFlowLayout;

@protocol UICollectionViewFetch <NSObject>

- (UICollectionViewCell *)cellForItemAtRow:(NSInteger)row column:(NSInteger)column;

@end

@interface UICollectionView (DNOMeshFetch)

@property (nonatomic, weak) id<UICollectionViewFetch> fetch; ///< 强行增加一个Fetch属性 根据row和column找到对应的cell

- (UICollectionViewCell *)cellForItemAtRow:(NSInteger)row column:(NSInteger)column;

@end
//////////////////////////////////////////////////

@protocol DNOMeshFlowLayoutDataSource <NSObject>

- (NSArray <NSNumber *>*)rowHeightArrayOfCollectionView:(UICollectionView *)collectionView;
- (NSArray <NSNumber *>*)columnWidthArrayOfCollectionView:(UICollectionView *)collectionView;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtRow:(NSInteger)row column:(NSInteger)column indexPath:(NSIndexPath *)indexPath;
@optional
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView cellEdgeInsetsForItemAtRow:(NSInteger)row column:(NSInteger)column indexPath:(NSIndexPath *)indexPath;

@end

@protocol DNOMeshFlowLayoutDelegate <NSObject>

@optional
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtRow:(NSInteger)row column:(NSInteger)column indexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtRow:(NSInteger)row column:(NSInteger)column indexPath:(NSIndexPath *)indexPath;
@end

#pragma mark -
#pragma mark  就是把ColletionView的代理和数据源转为Flowlayout的代理和数据源

IB_DESIGNABLE
@interface DNOMeshFlowLayout : UICollectionViewFlowLayout<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewFetch>

@property (nonatomic, weak) IBOutlet id<DNOMeshFlowLayoutDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<DNOMeshFlowLayoutDelegate> delegate;
@property (nonatomic, assign, readonly) IBInspectable BOOL flexibleWidth;  ///< 宽度是否可变(滑动) 仅在IB界面修改有效
@property (nonatomic, assign, readonly) IBInspectable BOOL flexibleHeight; ///< 高度是否可变(滑动) 仅在IB界面修改有效

/** 生成一个符合Mesh规范的CollectionView */
+ (UICollectionView *)meshCollectionViewWithDataSource:(id <DNOMeshFlowLayoutDataSource, DNOMeshFlowLayoutDelegate>)dataSource FlexibleWidth:(BOOL)flexibleWidth flexibleHeight:(BOOL)flexibleHeight;

+ (instancetype)flowLayoutWithFlexibleWidth:(BOOL)flexibleWidth flexibleHeight:(BOOL)flexibleHeight;

@end
