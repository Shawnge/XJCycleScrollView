//
//  ViewController.m
//  RMXCycleScrollView
//
//  Created by Shawnge on 2018/4/10.
//  Copyright © 2018年 Shawnge. All rights reserved.
//

#import "ViewController.h"
#import <XJCycleScrollView/XJCycleScrollView.h>

@interface ViewController () <XJCycleScrollViewDelegate, XJCycleScrollViewDataSource>

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) UILabel *label;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _images = @[@"http://pic7.nipic.com/20100510/4675637_204601085624_2.jpg",
                @"http://pic1.nipic.com/2008-08-25/200882582419423_2.jpg",
                @"http://pic18.nipic.com/20111220/7689042_004232500000_2.jpg",
                @"http://pic10.nipic.com/20101015/2030553_154724039288_2.jpg",
                @"http://pic23.nipic.com/20120831/10705080_091651684184_2.jpg",
                @"http://pic26.nipic.com/20130117/10560655_121003978000_2.jpg",
                @"http://pic106.huitu.com/res/20180519/754309_20180519220443623070_1.jpg",
                @"http://pic8.nipic.com/20100711/3035637_223449091645_2.jpg",
                @"http://pic13.nipic.com/20110424/3729052_214159427138_2.jpg",
                @"http://pic16.nipic.com/20110828/7988538_223843371000_2.jpg",];
    XJCycleScrollView *scrollView = [XJCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))];
    scrollView.autoScroll = NO;
//    scrollView.duration = 10.0f;
    scrollView.delegate = self;
    scrollView.dataSource = self;
    [self.view addSubview:scrollView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, CGRectGetWidth(self.view.bounds), 40)];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfItemInScrollView {
    return _images.count;
}

- (id)scrollView:(XJCycleScrollView *)scrollView imageForItemAtIndex:(NSInteger)index {
    NSString *urlString = _images[index];
    return [NSURL URLWithString:urlString];
}

- (void)scrollView:(XJCycleScrollView *)scrollView didScrollItemToIndex:(NSInteger)index {
     self.label.text = [NSString stringWithFormat:@"%@", @(index)];
}

- (void)scrollView:(XJCycleScrollView *)scrollView didSelectItemAtIndex:(NSInteger)index {
   
}

@end
