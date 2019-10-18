//
//  FCCollectionViewWaterFallLayout.m
//  FCCollectionViewWaterFallLayoutDemo
//
//  Created by fwzhou on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "FCCollectionViewWaterFallLayout.h"
#import "NSArray+DataProtect.h"
#import "FCCollectionDecorationView.h"

static NSString *decorationViewOfKind = @"decorationView";

@interface FCCollectionViewWaterFallLayout ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *itemLayoutAttributes;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *originHeaderLayoutAttributes;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *headerLayoutAttributes;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *originFooterLayoutAttributes;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *footerLayoutAttributes;

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *decorationAttributes;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *heightOfSections;

@property (nonatomic, assign) CGFloat contentHeight;

@end

@implementation FCCollectionViewWaterFallLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 注册一个可以包裹collectionview某个section所有位置（包括：sectionHeader、section中的cell及sectionFooter）的view
        // 主题包裹哪些，可以通过设置frame自定义
        [self registerClass:[FCCollectionDecorationView class] forDecorationViewOfKind:decorationViewOfKind];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [self invalidateLayout];
    
    self.contentHeight = 0.f;
    
    self.itemLayoutAttributes = [[NSMutableArray alloc] init];
    self.headerLayoutAttributes = [[NSMutableArray alloc] init];
    self.footerLayoutAttributes = [[NSMutableArray alloc] init];
    self.originHeaderLayoutAttributes = [[NSMutableArray alloc] init];
    self.originFooterLayoutAttributes = [[NSMutableArray alloc] init];
    self.decorationAttributes = [[NSMutableArray alloc] init];
    self.heightOfSections = [[NSMutableArray alloc] init];
    
    UICollectionView *collectionView = self.collectionView;
    NSInteger const numberOfSections = collectionView.numberOfSections;
    UIEdgeInsets const contentInset = collectionView.contentInset;
    CGFloat const contentWidth = collectionView.bounds.size.width - contentInset.left - contentInset.right;
    
    for (NSInteger section = 0; section < numberOfSections; section = section + 1) {
        NSInteger const columnOfSection = [_delegate collectionView:collectionView layout:self columnNumberAtSection:section];
        UIEdgeInsets const contentInsetOfSection = [self contentInsetForSection:section];
        CGFloat const minimumLineSpacing = [self minimumLineSpacingForSection:section];
        CGFloat const minimumInteritemSpacing = [self minimumInteritemSpacingForSection:section];
        CGFloat const contentWidthOfSection = contentWidth - contentInsetOfSection.left - contentInsetOfSection.right;
        CGFloat const itemWidth = (contentWidthOfSection - (columnOfSection - 1) * minimumInteritemSpacing) / columnOfSection;
        NSInteger numberOfItems = 0;
        if ([collectionView.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            numberOfItems = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
        }
        
        CGFloat headerHeight = 0.f;
        if ([_delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForHeaderInSection:)]) {
            headerHeight = [_delegate collectionView:collectionView layout:self referenceHeightForHeaderInSection:section];
        }
        UICollectionViewLayoutAttributes *headerLayoutAttribute = [[UICollectionViewLayoutAttributes alloc] init];
        headerLayoutAttribute.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        if (headerHeight > 0) {
            headerLayoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        }

        headerLayoutAttribute.frame = CGRectMake(0.f, _contentHeight, contentWidth, headerHeight);
        [_headerLayoutAttributes addObject:headerLayoutAttribute];
        
        [_originHeaderLayoutAttributes addObject:[headerLayoutAttribute copy]];
        
        CGFloat offsetOfColumns[columnOfSection];
        for (NSInteger i = 0; i < columnOfSection; i = i + 1) {
            offsetOfColumns[i] = headerHeight + contentInsetOfSection.top;
        }
        
        NSMutableArray *layoutAttributeOfSection = [NSMutableArray arrayWithCapacity:numberOfItems];
        for (NSInteger item = 0; item < numberOfItems; item = item + 1) {
            NSInteger currentColumn = 0;
            for (NSInteger i = 1; i < columnOfSection; i = i + 1) {
                if (offsetOfColumns[currentColumn] > offsetOfColumns[i]) {
                    currentColumn = i;
                }
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            CGFloat itemHeight = 0;
            if ([_delegate respondsToSelector:@selector(collectionView:layout:heightForRowAtIndexPath:itemWidth:)]) {
                itemHeight = [_delegate collectionView:collectionView layout:self heightForRowAtIndexPath:indexPath itemWidth:itemWidth];
            }
            CGFloat x = contentInsetOfSection.left + itemWidth * currentColumn + minimumInteritemSpacing * currentColumn;
            CGFloat y = offsetOfColumns[currentColumn] + (item >= columnOfSection ? minimumLineSpacing : 0.f);
            
            UICollectionViewLayoutAttributes *layoutAttbiture = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layoutAttbiture.frame = CGRectMake(x, y + _contentHeight, itemWidth, itemHeight);
            [layoutAttributeOfSection addObject:layoutAttbiture];
            
            offsetOfColumns[currentColumn] = (y + itemHeight);
        }
        [_itemLayoutAttributes addObject:layoutAttributeOfSection];
        
        CGFloat maxOffsetValue = offsetOfColumns[0];
        for (int i = 1; i < columnOfSection; i = i + 1) {
            if (offsetOfColumns[i] > maxOffsetValue) {
                maxOffsetValue = offsetOfColumns[i];
            }
        }
        maxOffsetValue = maxOffsetValue + contentInsetOfSection.bottom;
        
        CGFloat footerHeight = 0.f;
        if ([_delegate respondsToSelector:@selector(collectionView:layout:referenceHeightForFooterInSection:)]) {
            footerHeight = [_delegate collectionView:collectionView layout:self referenceHeightForFooterInSection:section];
        }
        UICollectionViewLayoutAttributes *footerLayoutAttribute = [[UICollectionViewLayoutAttributes alloc] init];
        footerLayoutAttribute.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        if (footerHeight > 0) {
            footerLayoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        }
        footerLayoutAttribute.frame = CGRectMake(0.f, _contentHeight + maxOffsetValue, contentWidth, footerHeight);
        [_footerLayoutAttributes addObject:footerLayoutAttribute];
        
        [_originFooterLayoutAttributes addObject:[footerLayoutAttribute copy]];
        
        CGFloat currentSectionHeight = maxOffsetValue + footerHeight;
        [_heightOfSections addObject:@(currentSectionHeight)];
        
        self.contentHeight = _contentHeight + currentSectionHeight;
        
        NSInteger itemCounts = [self.collectionView numberOfItemsInSection:section];
        // 当前section没有一个cell
        if (itemCounts <= 1) {
            continue;
        }
        
        // 第一个item
        UICollectionViewLayoutAttributes *firstItem =
        [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        
        // 最后一个item
        UICollectionViewLayoutAttributes *lastItem =
        [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:(itemCounts - 1) inSection:section]];
        
        // 当前section的包裹view的布局属性
        UICollectionViewLayoutAttributes *attribute =
        [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewOfKind withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        
        // 包裹view的起点x
        float x = CGRectGetMinX(firstItem.frame) - 10;
        // 包裹view的起点y，第一个cell位置
        float y = CGRectGetMinY(firstItem.frame) - 10;
        // 包裹view的width
        float width = 10 * 3 + CGRectGetWidth(firstItem.frame) * 2;
        if (itemCounts == 1) {
            // 只有一个cell，width特殊处理。否则有多个cell的时候，包裹view过大
            width = 10 * 2 + CGRectGetWidth(firstItem.frame);
        }
        // 包裹view的height
        float height = CGRectGetMaxY(lastItem.frame) - y;
        // 设置zIndex，包裹view显示在最下方
        attribute.zIndex = -1;
        // 此处未考虑、测试过反向布局
        attribute.frame = CGRectMake(x, y, width, height);
        [self.decorationAttributes addObject:attribute];
    }
}

- (CGSize)collectionViewContentSize
{
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGFloat width = CGRectGetWidth(self.collectionView.bounds) - contentInset.left - contentInset.right;
    CGFloat height = MAX(CGRectGetHeight(self.collectionView.bounds), _contentHeight);
    return CGSizeMake(width, height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray<UICollectionViewLayoutAttributes *> *result = [[NSMutableArray alloc] init];
    [_itemLayoutAttributes enumerateObjectsUsingBlock:^(NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributeOfSection, NSUInteger idx, BOOL *stop) {
         [layoutAttributeOfSection enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
             if (CGRectIntersectsRect(rect, attribute.frame)) {
                 [result addObject:attribute];
             }
          }];
     }];
    
    if (_sectionHeadersPinToVisibleBounds) {
        for (UICollectionViewLayoutAttributes *attribute in _headerLayoutAttributes) {
            NSInteger section = attribute.indexPath.section;
            UIEdgeInsets contentInsetOfSection = [self contentInsetForSection:section];
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *itemAttribute = [self layoutAttributesForItemAtIndexPath:firstIndexPath];
            if (!itemAttribute) {
                continue;
            }
            CGFloat headerHeight = CGRectGetHeight(attribute.frame);
            CGRect frame = attribute.frame;
            frame.origin.y = MIN(
                                 MAX(self.collectionView.contentOffset.y + _contentOffsetY, CGRectGetMinY(itemAttribute.frame)-headerHeight-contentInsetOfSection.top),
                                 CGRectGetMinY(attribute.frame)+[_heightOfSections[section] floatValue]-headerHeight
                                 );
            attribute.frame = frame;
            attribute.zIndex = (NSIntegerMax / 2) + section;
        }
    }
    // 先将header悬停，再判断header是否在屏幕
    [_headerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
         if (CGRectGetHeight(attribute.frame) > 0 &&
             CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
     }];
    
    [_footerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
         if (CGRectGetHeight(attribute.frame) > 0 &&
             CGRectIntersectsRect(rect, attribute.frame)) {
             [result addObject:attribute];
         }
     }];
    
    [_decorationAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<UICollectionViewLayoutAttributes *> *tempArray = [_itemLayoutAttributes fc_arrayWithIndex:indexPath.section];
    return [tempArray fc_objectWithIndex:indexPath.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [_headerLayoutAttributes fc_objectWithIndex:indexPath.section];
    }
    if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [_footerLayoutAttributes fc_objectWithIndex:indexPath.section];
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)originLayoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [_originHeaderLayoutAttributes fc_objectWithIndex:indexPath.section];
    }
    if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [_originFooterLayoutAttributes fc_objectWithIndex:indexPath.section];
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (_sectionHeadersPinToVisibleBounds) {
        return YES;
    } else {
        return [super shouldInvalidateLayoutForBoundsChange:newBounds];
    }
}

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
    CGFloat minimumLineSpacing = 0.f;
    if ([_delegate respondsToSelector:@selector(collectionView:layout:lineSpacingForSectionAtIndex:)]) {
        minimumLineSpacing = [_delegate collectionView:self.collectionView layout:self lineSpacingForSectionAtIndex:section];
    }
    return minimumLineSpacing;
}

- (CGFloat)minimumInteritemSpacingForSection:(NSInteger)section
{
    CGFloat minimumInteritemSpacing = 0.f;
    if ([_delegate respondsToSelector:@selector(collectionView:layout:interitemSpacingForSectionAtIndex:)]) {
        minimumInteritemSpacing = [_delegate collectionView:self.collectionView layout:self interitemSpacingForSectionAtIndex:section];
    }
    return minimumInteritemSpacing;
}

@end
