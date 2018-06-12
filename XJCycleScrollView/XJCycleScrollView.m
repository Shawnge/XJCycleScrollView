//
//  XJCycleScrollView.m
//  XJCycleScrollView
//
//  Created by Shawnge on 2018/4/10.
//  Copyright © 2018年 Shawnge. All rights reserved.
//

#import "XJCycleScrollView.h"
#import "XJCycleButton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <EllipsePageControl/EllipsePageControl.h>

@interface XJCycleScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *mainView;

@property (nonatomic, strong) NSArray<XJCycleButton *> *imageButtons;

@property (nonatomic, assign) NSInteger totalPage;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) EllipsePageControl *pageControl;

@end


@implementation XJCycleScrollView

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame {
    XJCycleScrollView *scrollView = [[XJCycleScrollView alloc] initWithFrame:frame];
    return scrollView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperty];
        [self initSubviews];
    }
    return self;
}

- (void)dealloc {
    [self invalidateTimer];
}

- (void)initProperty {
    _currentPage = 0;
    _duration = 5.0f;
    _autoScroll = YES;
    _hideForSinglePage = YES;
}

- (void)initSubviews {
    [self addSubview:self.mainView];
    
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger index = 0; index < 3; index++) {
        XJCycleButton *button = [[XJCycleButton alloc] init];
        button.tag = index;
        button.frame = CGRectMake(CGRectGetWidth(self.mainView.bounds) * index, 0, CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds));
        button.adjustsImageWhenHighlighted = NO;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:button];
        [buttons addObject:button];
    }
    self.imageButtons = [buttons copy];
    
    [self addSubview:self.pageControl];
    self.pageControl.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 30, CGRectGetWidth(self.bounds), 30);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self invalidateTimer];
    } else {
        [self reloadData];
    }
}

- (void)reloadData {
    self.totalPage = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemInScrollView)]) {
        self.totalPage = [self.dataSource numberOfItemInScrollView];
    }
    self.pageControl.numberOfPages = self.totalPage;
    self.pageControl.hidden = self.hideForSinglePage ? (self.totalPage <= 1 ? YES : NO) : NO;
    self.autoScroll = self.totalPage <= 1 ? NO : YES;
    
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:self.totalPage];
    if ([self.dataSource respondsToSelector:@selector(scrollView:imageForItemAtIndex:)]) {
        for (NSInteger index = 0; index < self.totalPage; index++) {
            id image = [self.dataSource scrollView:self imageForItemAtIndex:index];
            NSAssert([image isKindOfClass:[NSURL class]] || [image isKindOfClass:[UIImage class]], @"必须是NSURL或者UIImage");
            [tmp addObject:image];
        }
    }
    self.images = [tmp copy];
    [self resetScrollView:self.mainView.contentOffset.x];
}

#pragma mark - timer
- (void)invalidateTimer {
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    self.timer = nil;
}

- (void)resumeTimer {
    [self invalidateTimer];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

#pragma mark - Actions
- (void)buttonClick:(XJCycleButton *)sender {
    if ([self.delegate respondsToSelector:@selector(scrollView:didSelectItemAtIndex:)]) {
        [self.delegate scrollView:self didSelectItemAtIndex:self.currentPage];
    }
}

- (void)timerRun:(NSTimer *)timer {
    [self.mainView setContentOffset:CGPointMake(2 * CGRectGetWidth(self.mainView.bounds), 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self resumeTimer];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resetScrollView:scrollView.contentOffset.x];
}

- (void)resetScrollView:(CGFloat)offsetX {
    if (self.images.count == 0) {
        return;
    }
    
    CGFloat tmp = offsetX / CGRectGetWidth(self.mainView.bounds);
    if (fabs(tmp) <= 0.000001 || fabs(tmp - 1) < 0.000001 || fabs(tmp - 2) < 0.000001) {
        self.currentPage = [self currentPageWithIndex:(tmp - 1 + self.currentPage)];
        NSArray *indexs = @[@([self previousPageOfCurrentPage:self.currentPage]), @(self.currentPage), @([self nextPageOfCurrentPage:self.currentPage])];
        for (NSInteger index = 0; index < 3; index++) {
            [self updateButton:self.imageButtons[index] withIndex:[indexs[index] integerValue]];
        }
        self.mainView.contentOffset = CGPointMake(CGRectGetWidth(self.mainView.bounds), 0);
        if ([self.delegate respondsToSelector:@selector(scrollView:didScrollItemToIndex:)]) {
            [self.delegate scrollView:self didScrollItemToIndex:self.currentPage];
        }
        self.pageControl.currentPage = self.currentPage;
    }
}

- (void)updateButton:(XJCycleButton *)button withIndex:(NSInteger)index {
    id image = self.images[index];
    if ([image isKindOfClass:[NSURL class]]) {
        [button.displayImageView sd_setImageWithURL:image placeholderImage:self.placeholderImage];
    } else if ([image isKindOfClass:[UIImage class]]) {
        button.displayImageView.image = image;
    }
}

#pragma mark - getter and setter
- (UIScrollView *)mainView {
    if (!_mainView) {
        _mainView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainView.bounces = NO;
        _mainView.delegate = self;
        _mainView.showsVerticalScrollIndicator = NO;
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.contentSize = CGSizeMake(3 * CGRectGetWidth(_mainView.bounds), CGRectGetHeight(_mainView.bounds));
        _mainView.pagingEnabled = YES;
        _mainView.contentOffset = CGPointMake(CGRectGetWidth(_mainView.bounds), 0);
    }
    return _mainView;
}

- (EllipsePageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[EllipsePageControl alloc] initWithFrame:CGRectZero];
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = 0;
        _pageControl.controlSize = 4;
        _pageControl.controlSpacing = 6;
        _pageControl.otherColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _pageControl.currentColor = [UIColor whiteColor];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    if (self.autoScroll) {
        [self resumeTimer];
    }
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    if (autoScroll) {
        [self resumeTimer];
    } else {
        [self invalidateTimer];
    }
}

#pragma mark - Page Index
- (NSInteger)currentPageWithIndex:(NSInteger)index {
    if (self.totalPage > 0) {
        NSInteger tmp = index % self.totalPage;
        return  tmp < 0 ? self.totalPage - 1 : tmp;
    }
    return 0;
}

- (NSInteger)previousPageOfCurrentPage:(NSInteger)currentPage {
    if (currentPage <= 0) {
        return self.totalPage - 1;
    }
    return currentPage - 1;
}

- (NSInteger)nextPageOfCurrentPage:(NSInteger)currentPage {
    if (currentPage >= self.totalPage - 1) {
        return 0;
    }
    return currentPage + 1;
}

@end
