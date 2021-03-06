//
//  FCTestCollectionViewCell.m
//  FCCollectionViewWaterFallLayoutDemo
//
//  Created by fwzhou on 2020/1/9.
//  Copyright © 2020 iOS. All rights reserved.
//

#import "FCTestCollectionViewCell.h"
#import "FCCollectionViewWaterFallLayout.h"

@interface FCTestCollectionViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, FCCollectionViewWaterFallLayoutDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation FCTestCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (void)update
{
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    } else {
        return 30;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])
                                                                                forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor purpleColor];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionReusableViewHeader" forIndexPath:indexPath];
        header.backgroundColor = [UIColor orangeColor];
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableViewFooter" forIndexPath:indexPath];
        footer.backgroundColor = [UIColor redColor];
        return footer;
    }
    return nil;
}

#pragma mark - FCCollectionViewWaterFallLayoutDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout columnNumberAtSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout heightForRowAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth
{
    if (indexPath.item % 2 == 0) {
        return 13;
    } else {
        return 15;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout referenceHeightForHeaderInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout referenceHeightForFooterInSection:(NSInteger)section
{
    return 2;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        FCCollectionViewWaterFallLayout *flowLayout = [[FCCollectionViewWaterFallLayout alloc] init];
        flowLayout.sectionHeadersPinToVisibleBounds = YES;
        flowLayout.delegate = self;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flowLayout];
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"UICollectionReusableViewHeader"];
        
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:@"UICollectionReusableViewFooter"];
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _collectionView.backgroundColor = [UIColor blueColor];
    }
    return _collectionView;
}

@end
