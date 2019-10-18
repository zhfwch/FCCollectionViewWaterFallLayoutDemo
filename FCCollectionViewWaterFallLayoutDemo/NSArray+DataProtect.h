//
//  NSArray+DataProtect.h
//  FCCollectionViewWaterFallLayoutDemo
//
//  Created by fwzhou on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (DataProtect)

- (nullable id)fc_objectWithIndex:(NSInteger)index;

- (nullable NSArray*)fc_arrayWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
