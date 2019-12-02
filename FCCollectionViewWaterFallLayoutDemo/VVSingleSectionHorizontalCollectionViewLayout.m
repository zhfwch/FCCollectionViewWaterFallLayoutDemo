//
//  VVSingleSectionHorizontalCollectionViewLayout.m
//  Vova
//
//  Created by fwzhou on 2019/5/8.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "VVSingleSectionHorizontalCollectionViewLayout.h"
#import "NSArray+DataProtect.h"

@interface VVSingleSectionHorizontalCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *itemLayoutAttributes;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *headerLayoutAttributes;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *footerLayoutAttributes;

@property (nonatomic, assign) CGFloat contentWidth;

@end

@implementation VVSingleSectionHorizontalCollectionViewLayout

- (void)prepareLayout
{
    [super prepareLayout];

    self.contentWidth = 0.0;

    self.itemLayoutAttributes = [NSMutableArray array];
    self.headerLayoutAttributes = [NSMutableArray array];
    self.footerLayoutAttributes = [NSMutableArray array];

    [self invalidateLayout];

    UICollectionView *collectionView = self.collectionView;
    NSInteger const numberOfSections = collectionView.numberOfSections;
    UIEdgeInsets const contentInset = collectionView.contentInset;
    CGFloat const contentHeight = collectionView.bounds.size.height - contentInset.top - contentInset.bottom;
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        UIEdgeInsets const contentInsetOfSection = [self contentInsetForSection:section];
        CGFloat const minimumLineSpacing = [self minimumLineSpacingForSection:section];
        CGFloat const contentHeightOfSection = contentHeight - contentInsetOfSection.top - contentInsetOfSection.bottom;
        CGFloat const itemHeight = contentHeightOfSection;

        CGFloat headerWidth = 0.0;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceWidthForHeaderInSection:)]) {
            headerWidth = [self.delegate collectionView:collectionView layout:self referenceWidthForHeaderInSection:section];
        }
        UICollectionViewLayoutAttributes *headerLayoutAttribute = [[UICollectionViewLayoutAttributes alloc] init];
        headerLayoutAttribute.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        if (headerWidth > 0) {
            headerLayoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        }

        headerLayoutAttribute.frame = CGRectMake(self.contentWidth, 0, headerWidth, contentHeight);
        [self.headerLayoutAttributes addObject:headerLayoutAttribute];
        self.contentWidth = self.contentWidth + headerWidth;

        NSInteger numberOfItems = 0;
        if ([collectionView.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            numberOfItems = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
        }
        self.contentWidth = self.contentWidth + contentInsetOfSection.left;
        NSMutableArray *layoutAttributeOfSection = [NSMutableArray arrayWithCapacity:numberOfItems];
        for (NSInteger item = 0; item < numberOfItems; item = item + 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGFloat itemWidth = 0;
            if ([_delegate respondsToSelector:@selector(collectionView:layout:widthForRowAtIndexPath:)]) {
                itemWidth = [_delegate collectionView:collectionView layout:self widthForRowAtIndexPath:indexPath];
            }
            CGFloat x = self.contentWidth;
            if (item != 0 &&
                item < numberOfItems) {
                x = x + minimumLineSpacing;
            }
            CGFloat y = contentInsetOfSection.top;

            UICollectionViewLayoutAttributes *layoutAttbiture = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layoutAttbiture.frame = CGRectMake(x, y, itemWidth, itemHeight);
            [layoutAttributeOfSection addObject:layoutAttbiture];
            self.contentWidth = x + itemWidth;
            if (item == numberOfItems - 1) {
                self.contentWidth = self.contentWidth + contentInsetOfSection.right;
            }
        }
        [self.itemLayoutAttributes addObject:layoutAttributeOfSection];

        CGFloat footerWidth = 0.0;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceWidthForFooterInSection:)]) {
            footerWidth = [self.delegate collectionView:collectionView layout:self referenceWidthForFooterInSection:section];
        }
        UICollectionViewLayoutAttributes *footerLayoutAttribute = [[UICollectionViewLayoutAttributes alloc] init];
        footerLayoutAttribute.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        if (footerWidth > 0) {
            footerLayoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        }
        footerLayoutAttribute.frame = CGRectMake(self.contentWidth, 0, footerWidth, contentHeight);
        [self.footerLayoutAttributes addObject:footerLayoutAttribute];

        self.contentWidth = self.contentWidth + footerWidth;
    }
    
    [self.itemLayoutAttributes enumerateObjectsUsingBlock:^(NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributeOfSection, NSUInteger idx, BOOL *stop) {
        [self convertRigthToLeft:layoutAttributeOfSection];
    }];
    [self convertRigthToLeft:self.headerLayoutAttributes];
    [self convertRigthToLeft:self.footerLayoutAttributes];
}

- (CGSize)collectionViewContentSize
{
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGFloat width = MAX(CGRectGetWidth(self.collectionView.bounds), self.contentWidth);
    CGFloat height = CGRectGetHeight(self.collectionView.bounds) - contentInset.top - contentInset.bottom;
    return CGSizeMake(width, height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray<UICollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    [self.itemLayoutAttributes enumerateObjectsUsingBlock:^(NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributeOfSection, NSUInteger idx, BOOL *stop) {
        [layoutAttributeOfSection enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
            if (CGRectIntersectsRect(rect, attribute.frame)) {
                [result addObject:attribute];
            }
        }];
    }];
    
    [self.headerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (CGRectGetWidth(attribute.frame) > 0 &&
            CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    
    [self.footerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (CGRectGetWidth(attribute.frame) > 0 &&
            CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
         }
    }];

    return result;
}

- (void)convertRigthToLeft:(NSMutableArray<UICollectionViewLayoutAttributes *> *)layoutAttributesArray
{
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        // 反向布局
        for (UICollectionViewLayoutAttributes *layout in layoutAttributesArray) {
            CGRect frame = layout.frame;
            frame.origin.x = MAX(CGRectGetWidth(self.collectionView.bounds), self.contentWidth) - CGRectGetMinX(frame) - CGRectGetWidth(frame);
            layout.frame = frame;
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<UICollectionViewLayoutAttributes *> *tempArray = [_itemLayoutAttributes vv_arrayWithIndex:indexPath.section];
    return [tempArray vv_objectWithIndex:indexPath.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [_headerLayoutAttributes vv_objectWithIndex:indexPath.section];
    }
    if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [_footerLayoutAttributes vv_objectWithIndex:indexPath.section];
    }
    return nil;
}

#pragma mark - Private
- (UIEdgeInsets)contentInsetForSection:(NSInteger)section
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if ([_delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        edgeInsets = [_delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    return edgeInsets;
}

- (CGFloat)minimumLineSpacingForSection:(NSInteger)section
{
    CGFloat minimumLineSpacing = 0;
    if ([_delegate respondsToSelector:@selector(collectionView:layout:lineSpacingForSectionAtIndex:)]) {
        minimumLineSpacing = [_delegate collectionView:self.collectionView layout:self lineSpacingForSectionAtIndex:section];
    }
    return minimumLineSpacing;
}

@end
