//
//  NSArray+DataProtect.m
//  FCCollectionViewWaterFallLayoutDemo
//
//  Created by fwzhou on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "NSArray+DataProtect.h"

@implementation NSArray (DataProtect)

- (nullable id)fc_objectWithIndex:(NSInteger)index
{
    if (index < 0) {
        return nil;
    }
    if (index < self.count) {
        return self[index];
    }
    return nil;
}

- (nullable NSArray*)fc_arrayWithIndex:(NSInteger)index
{
    id value = [self fc_objectWithIndex:index];
    if (value == nil || value == [NSNull null]) {
        return nil;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}

@end
