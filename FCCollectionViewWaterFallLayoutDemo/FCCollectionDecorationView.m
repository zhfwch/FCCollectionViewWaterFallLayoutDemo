//
//  FCCollectionDecorationView.m
//  FCCollectionViewWaterFallLayoutDemo
//
//  Created by fwzhou on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "FCCollectionDecorationView.h"

@implementation FCCollectionDecorationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        self.layer.cornerRadius = 4;
    }
    return self;
}

@end
