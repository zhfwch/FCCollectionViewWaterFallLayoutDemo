//
//  VVSingleSectionHorizontalCollectionViewLayout.h
//  Vova
//
//  Created by fwzhou on 2019/5/8.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VVSingleSectionHorizontalCollectionViewLayout;

@protocol VVSingleSectionHorizontalCollectionViewLayoutDelegate <NSObject>

@required
/// cell width
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(VVSingleSectionHorizontalCollectionViewLayout *)collectionViewLayout widthForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
/// header width
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(VVSingleSectionHorizontalCollectionViewLayout *)collectionViewLayout referenceWidthForHeaderInSection:(NSInteger)section;

/// footer width
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(VVSingleSectionHorizontalCollectionViewLayout *)collectionViewLayout referenceWidthForFooterInSection:(NSInteger)section;

/// 每个区的边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(VVSingleSectionHorizontalCollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

/// 每个 item 之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(VVSingleSectionHorizontalCollectionViewLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;

@end

/// 一列只有一行
@interface VVSingleSectionHorizontalCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<VVSingleSectionHorizontalCollectionViewLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
