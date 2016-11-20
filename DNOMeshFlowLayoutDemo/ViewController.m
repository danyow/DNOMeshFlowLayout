//
//  ViewController.m
//  DNOMeshFlowLayoutDemo
//
//  Created by Danyow on 2016/11/20.
//  Copyright © 2016年 Danyow.Ed. All rights reserved.
//

#import "ViewController.h"
#import "DNOMeshFlowLayout.h"

@interface ViewController ()<DNOMeshFlowLayoutDelegate, DNOMeshFlowLayoutDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *meshCollectionView;

@property (nonatomic, strong) NSArray <NSNumber *>*demoNumberArray;
@property (weak, nonatomic) IBOutlet UISwitch *flexibleWidthSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *flexibleHeightSwitch;

@end

static NSString * const kReuseIdentifier = @"ID";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.meshCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kReuseIdentifier];
    
}

#pragma mark -
#pragma mark  DNOMeshFlowLayoutDataSource

- (NSArray<NSNumber *> *)rowHeightArrayOfCollectionView:(UICollectionView *)collectionView
{
    return self.demoNumberArray;
}

- (NSArray<NSNumber *> *)columnWidthArrayOfCollectionView:(UICollectionView *)collectionView
{
    return self.demoNumberArray;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtRow:(NSInteger)row column:(NSInteger)column indexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    cell.hidden = NO;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    if (self.navigationController.viewControllers.count > 1) {
        /** D */
        if (row > 0 && row < 11) {
            if (column == 3 || column == 4 || column == 8 || column == 9) {
                if (row == 3) {
                    cell.contentView.backgroundColor = [UIColor blackColor];
                } else {
                    cell.hidden = YES;
                }
            }
            if (row == 1 || row == 2 || row == 9 || row == 10) {
                if (column == 2) {
                    cell.contentView.backgroundColor = [UIColor blackColor];
                } else {
                    if (row == 1 || row == 10) {
                        cell.hidden = column > 2 && column < 9;
                    } else {
                        cell.hidden = column > 2 && column < 10;
                    }
                }
            }
        }
    } else {
        if (row == 1) {
            if (column > 1 && column < 4) {
                cell.hidden = YES;
            }
        }
        if (column == 2) {
            if (row > 2 && row < 5) {
                cell.hidden = YES;
            }
        }
        UILabel *label;
        if ([cell.contentView.subviews.lastObject isKindOfClass:[UILabel class]]) {
            label = cell.contentView.subviews.lastObject;
        } else {
            label = [[UILabel alloc] initWithFrame:cell.bounds];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            [label setMinimumScaleFactor:8];
            label.numberOfLines = 0;
            [cell.contentView addSubview:label];
        }
        label.text = [NSString stringWithFormat:@"%zd:%zd", row, column];
        label.frame = cell.bounds;
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView cellEdgeInsetsForItemAtRow:(NSInteger)row column:(NSInteger)column indexPath:(NSIndexPath *)indexPath
{
    if (self.navigationController.viewControllers.count > 1) {
        /** D */
        if (row > 0 && row < 11) {
            
            if (column == 3 || column == 4 || column == 8 || column == 9) {
                if (row == 3) {
                    return UIEdgeInsetsMake(0, 0, 60 * 5, 0);
                }
            }
            
            if (row == 1 || row == 2 || row == 9 || row == 10) {
                if (column == 2) {
                    return UIEdgeInsetsMake(0, 0, 0, (row == 1 || row == 10 ? 6 : 7) * 60);
                }
            }
        }
    } else {
        
        if (row == 1) {
            if (column == 1) {
                return UIEdgeInsetsMake(0, 0, 0, 60 * 2);
            }
        }
        if (row == 2) {
            if (column == 2) {
                return UIEdgeInsetsMake(0, 0, 60 * 2, 0);
            }
        }
        
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark -
#pragma mark  DNOMeshFlowLayoutDelegate

#pragma mark -
#pragma mark  event handle

- (IBAction)buttonPressed:(UIButton *)sender
{
    
    NSInteger count = self.navigationController.viewControllers.count;
    if (count > 1) {
        return;
    }
    if ([sender.currentTitle isEqualToString:@"生成"]) {
        [self.meshCollectionView removeFromSuperview];
        self.meshCollectionView = [DNOMeshFlowLayout meshCollectionViewWithDataSource:self FlexibleWidth:self.flexibleWidthSwitch.on flexibleHeight:self.flexibleHeightSwitch.on];
        [self.view addSubview:self.meshCollectionView];
        [self.meshCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kReuseIdentifier];
        self.meshCollectionView.frame = CGRectMake(0, CGRectGetMaxY(sender.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(sender.frame));
        
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSString *identifier = nil;
        UIViewController *viewController;
        if ([sender.currentTitle isEqualToString:@"宽高固定"]) {
            identifier = @"00";
        } else if ([sender.currentTitle isEqualToString:@"宽固定高可变"]) {
            identifier = @"01";
        } else if ([sender.currentTitle isEqualToString:@"宽可变高固定"]) {
            identifier = @"10";
        } else if ([sender.currentTitle isEqualToString:@"宽高可变"]) {
            identifier = @"11";
        }
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (NSArray <NSNumber *>*)demoNumberArray
{
    if (!_demoNumberArray) {
        NSInteger count = 12;
        NSMutableArray *numberArray = [[NSMutableArray alloc] initWithCapacity:count];
        for (NSInteger i = 0; i < count; ++i) {
            [numberArray addObject:@60];
        }
        _demoNumberArray = numberArray.copy;
    }
    return _demoNumberArray;
}

@end
