//
//  XJCycleScrollView.h
//  XJCycleScrollView
//
//  Created by Shawnge on 2018/4/10.
//  Copyright © 2018年 Shawnge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XJCycleScrollView;
@protocol XJCycleScrollViewDataSource <NSObject>
@required
- (NSInteger)numberOfItemInScrollView;

- (id)scrollView:(XJCycleScrollView *)scrollView imageForItemAtIndex:(NSInteger)index;

@end

@protocol XJCycleScrollViewDelegate <NSObject>

- (void)scrollView:(XJCycleScrollView *)scrollView didScrollItemToIndex:(NSInteger)index;

- (void)scrollView:(XJCycleScrollView *)scrollView didSelectItemAtIndex:(NSInteger)index;

@end

@interface XJCycleScrollView : UIView

@property (nonatomic, weak) id<XJCycleScrollViewDataSource> dataSource;

@property (nonatomic, weak) id<XJCycleScrollViewDelegate> delegate;

@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, assign) BOOL autoScroll;

@property (nonatomic, assign) BOOL hideForSinglePage; //default is YES

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame;

- (void)reloadData;

@end
