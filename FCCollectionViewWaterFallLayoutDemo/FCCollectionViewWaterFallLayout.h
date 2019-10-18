//
//  FCCollectionViewWaterFallLayout.h
//  FCCollectionViewWaterFallLayoutDemo
//
//  Created by fwzhou on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FCCollectionViewWaterFallLayout;

@protocol FCCollectionViewWaterFallLayoutDelegate <NSObject>

@required
/// 每个区多少列
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout columnNumberAtSection:(NSInteger )section;

/// cell height
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout heightForRowAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;

@optional
/// header height
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout referenceHeightForHeaderInSection:(NSInteger)section;

/// footer height
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout referenceHeightForFooterInSection:(NSInteger)section;

/// 每个区的边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

/// 每个区多少中行距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;

/// 每个 item 之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FCCollectionViewWaterFallLayout*)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;

@end

@interface FCCollectionViewWaterFallLayout : UICollectionViewLayout

@property (nonatomic, weak) id<FCCollectionViewWaterFallLayoutDelegate> delegate;

/// header是否悬停
@property (nonatomic, assign) BOOL sectionHeadersPinToVisibleBounds;
/// header悬停起始位置偏移量
@property (nonatomic, assign) CGFloat contentOffsetY;

/// 未悬停的header的布局属性
- (UICollectionViewLayoutAttributes *)originLayoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
