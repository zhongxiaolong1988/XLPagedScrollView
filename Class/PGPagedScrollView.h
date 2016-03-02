//
//  PGPagedScrollView.h
//  Camera360
//
//  Created by ZhongXiaolong on 13-11-8.
//  Copyright (c) 2013年 Pinguo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#define PGPagedScroll_ImageViewBaseTag                  10000

@protocol PGPagedScrollViewDelegate<NSObject>

@optional
/**
 *  当手动或滑动到某个索引的时候会被调用，只有当索引有改变时才会被调用
 *
 *  @param aIndex 当前滑动到的索引
 */
- (void)didScrolledToIndex:(NSInteger)aIndex;

/**
 *  当控件被点击时回调
 *
 *  @param aIndex 被点击的索引
 */
- (void)didSelectedAtIndex:(NSInteger)aIndex;

@end

@interface PGPagedScrollView : UIView<UIScrollViewDelegate>
{
    /** 保存图片数据的数组 */
    NSMutableArray *_imagesArr;

    /** scrollview */
    UIScrollView *_scrollView;

    /** 页面控制 */
    UIPageControl *_pagedControl;

    /** 自动播放的Timer */
    NSTimer *_autoPlayTimer;

    /** 是否正在自动播放 */
    BOOL _isPlaying;

    /** 每次滑动时上次的值 */
    NSInteger _lastPage;
}

@property (nonatomic, weak) id<PGPagedScrollViewDelegate> delegate;

/** 表示是否可循环滑动 */
@property (nonatomic, readonly) BOOL isRepeat;

/** 表示是否自动播放 */
@property (nonatomic, readonly) BOOL isAutoPaly;

/** 表示自动播放时是否向右，YES为向右，NO为向左，默认为向右 */
@property (nonatomic, assign) BOOL isScrollToRight;

/** 表示自动播放时的每张图片的切换时间 */
@property (nonatomic, assign) float playInterval;


/** 是否显示分页控件 */
@property (nonatomic, assign) BOOL isShowPagedControl;

/**
 *  初始化滑动控件
 *
 *  @param aFrame           控件大小
 *  @param aImageArr        图片数据数组
 *
 *  @return 滑动播放控件对象
 */
- (instancetype)initWithFrame:(CGRect)frame;


/**
 *  初始化滑动控件
 *
 *  @param aFrame           控件大小
 *  @param aImageArr        图片数据数组
 *  @param aIsRepeat        是否可重复手动滑动
 *
 *  @return 滑动播放控件对象
 */
- (PGPagedScrollView *)initWithFrame:(CGRect)aFrame
                            imageArr:(NSArray *)aImageArr
                            isRepeat:(BOOL)aIsRepeat;

/**
 *  初始化滑动控件
 *
 *  @param aFrame           控件大小
 *  @param aImageArr        图片数据数组
 *  @param aIsAutoPlay      是否自动播放
 *
 *  @return 滑动播放控件对象
 */
- (PGPagedScrollView *)initWithFrame:(CGRect)aFrame
                            imageArr:(NSArray *)aImageArr
                          isAutoPlay:(BOOL)aIsAutoPlay;

/**
 *  初始化滑动控件
 *
 *  @param aFrame           控件大小
 *  @param aImageArr        图片数据数组
 *  @param aIsAutoPlay      是否自动播放
 *  @param aIsRepeat        是否可重复手动滑动
 *  @param aIsScrollToRight 自动播放时是否向右
 *  @param aChangeTime      每张图的自动切换时间
 *
 *  @return 滑动播放控件对象
 */
- (PGPagedScrollView *)initWithFrame:(CGRect)aFrame
                            imageArr:(NSArray *)aImageArr
                          isAutoPlay:(BOOL)aIsAutoPlay
                            isRepeat:(BOOL)aIsRepeat
                     isScrollToRight:(BOOL)aIsScrollToRight
                            interval:(float)aChangeTime;

/**
 *  开始自动播放
 *
 *  @return 返回YES表示正常开始，返回NO表示没有设置自动播放属性为YES
 */
- (BOOL)startPlay;

/**
 *  停止自动播放
 *
 *  @return 返回YES表示正常停止，返回NO表示没有设置自动播放属性为YES
 */
- (BOOL)stopPlay;

@end
