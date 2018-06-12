//
//  XJCycleButton.m
//  XJCycleScrollView
//
//  Created by Shawnge on 2018/6/12.
//  Copyright © 2018 Shawnge. All rights reserved.
//

#import "XJCycleButton.h"

@implementation XJCycleButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    [self addSubview:self.displayImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayImageView.frame = self.bounds;
}

#pragma mark - getter and setter
- (UIImageView *)displayImageView
{
    if (!_displayImageView) {
        _displayImageView = [[UIImageView alloc] init];
        _displayImageView.clipsToBounds = YES;
        _displayImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _displayImageView;
}

@end
