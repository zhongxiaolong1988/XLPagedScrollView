//
//  PGPagedScrollView.m
//  Camera360
//
//  Created by ZhongXiaolong on 13-11-8.
//  Copyright (c) 2013年 Pinguo. All rights reserved.
//

#import "PGPagedScrollView.h"
#import "PGL-Core.h"



/** 默认切换图片的时间 */
static NSInteger const PGPagedScroll_DefaultChangeTime = 3;


// Debug levels: off, fatal, error, warn, notice, info, debug


@implementation PGPagedScrollView

#pragma mark 初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code

        [self initUI];
    }
    return self;
}


- (PGPagedScrollView *)initWithFrame:(CGRect)aFrame
                            imageArr:(NSArray *)aImageArr
                          isAutoPlay:(BOOL)aIsAutoPlay
{
    return [self initWithFrame:aFrame
                      imageArr:aImageArr
                    isAutoPlay:aIsAutoPlay
                      isRepeat:YES
               isScrollToRight:YES
                      interval:PGPagedScroll_DefaultChangeTime];
}


- (PGPagedScrollView *)initWithFrame:(CGRect)aFrame
                            imageArr:(NSArray *)aImageArr
                            isRepeat:(BOOL)aIsRepeat
{
    return [self initWithFrame:aFrame
                      imageArr:aImageArr
                    isAutoPlay:YES
                      isRepeat:aIsRepeat
               isScrollToRight:YES
                      interval:PGPagedScroll_DefaultChangeTime];
}


- (PGPagedScrollView *)initWithFrame:(CGRect)aFrame
                            imageArr:(NSArray *)aImageArr
                          isAutoPlay:(BOOL)aIsAutoPlay
                            isRepeat:(BOOL)aIsRepeat
                     isScrollToRight:(BOOL)aIsScrollToRight
                            interval:(float)aChangeTime
{
    if (aIsRepeat == NO)
    {
        _isAutoPaly = NO;
    }
    else if (aIsAutoPlay == NO)
    {
        _isRepeat = NO;
    }
    else
    {
        _isRepeat = aIsRepeat;
        _isAutoPaly = aIsAutoPlay;
    }

    _isScrollToRight = aIsScrollToRight;
    _imagesArr = [NSMutableArray new];
    [_imagesArr addObjectsFromArray:aImageArr];

    if (aChangeTime > 0)
    {
        _playInterval = aChangeTime;
    }
    else
    {
        _playInterval = PGPagedScroll_DefaultChangeTime;
    }


    return [self initWithFrame:aFrame];
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

- (void)initUI
{
    // REV @zxl method line > 100
    if ((_imagesArr == nil) || ([_imagesArr count] == 0))
    {
        PGLogDebug(@"滑动控件没有图片数据");
        return;
    }

    self.isShowPagedControl = YES;

    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];

    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.userInteractionEnabled = YES;

    [self addSubview:_scrollView];

    NSUInteger imageCount = [_imagesArr count];

    /** 如果需要重复，在前后再各添加一个imageview */
    if ([_imagesArr count] == 1)
    {
        _isRepeat = NO;
    }

    if (_isRepeat && [_imagesArr count] > 1)
    {
        for (int i = 1; i <= [_imagesArr count]; i++)
        {
            UIImage *image = _imagesArr[i - 1];

            PGAssert([image isKindOfClass:[UIImage class]], @"滑动控件，数据出错，不是图片！！！");

            if (![image isKindOfClass:[UIImage class]])
            {
                PGLogError(@"滑动控件，数据出错，不是图片");
                return;
            }

            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.bounds.size.width,
                                                                                   0,
                                                                                   self.bounds.size.width,
                                                                                   self.bounds.size.height)];

            imageView.tag = PGPagedScroll_ImageViewBaseTag + i * 100;
            imageView.userInteractionEnabled = YES;
            [imageView setImage:image];
            [_scrollView addSubview:imageView];

            UITapGestureRecognizer *tapGs
                    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTap:)];
            [imageView addGestureRecognizer:tapGs];
        }

        UIImageView *firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    self.bounds.size.width,
                                                                                    self.bounds.size.height)];

        firstImageView.tag = PGPagedScroll_ImageViewBaseTag + [_imagesArr count] * 100 + 1;
        firstImageView.userInteractionEnabled = YES;
        [firstImageView setImage:[_imagesArr lastObject]];
        [_scrollView addSubview:firstImageView];

        UITapGestureRecognizer *addFirstGs
                = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTap:)];
        [firstImageView addGestureRecognizer:addFirstGs];


        const struct CGRect frame = CGRectMake(self.bounds.size.width * ([_imagesArr count] + 1),
                                               0,
                                               self.bounds.size.width,
                                               self.bounds.size.height);
        UIImageView *lastImageView = [[UIImageView alloc] initWithFrame:frame];

        lastImageView.tag = PGPagedScroll_ImageViewBaseTag + 100 + 1;

        [lastImageView setImage:_imagesArr[0]];
        lastImageView.userInteractionEnabled = YES;
        [_scrollView addSubview:lastImageView];

        UITapGestureRecognizer *addLastGs
                = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTap:)];

        [lastImageView addGestureRecognizer:addLastGs];

        _scrollView.contentSize = CGSizeMake((imageCount + 2) * self.bounds.size.width, self.bounds.size.height);
        [_scrollView scrollRectToVisible:CGRectMake(self.bounds.size.width,
                                                    0,
                                                    self.bounds.size.width,
                                                    self.bounds.size.height)
                                animated:NO];
    }
    else
    {
        for (int i = 0; i < [_imagesArr count]; i++)
        {
            UIImage *image = _imagesArr[i];

            PGAssert([image isKindOfClass:[UIImage class]], @"滑动控件，数据出错，不是图片！！！");

            if (![image isKindOfClass:[UIImage class]])
            {
                PGLogError(@"滑动控件，数据出错，不是图片");
                return;
            }

            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.bounds.size.width,
                                                                                   0,
                                                                                   self.bounds.size.width,
                                                                                   self.bounds.size.height)];
            imageView.tag = PGPagedScroll_ImageViewBaseTag + i * 100;

            imageView.userInteractionEnabled = YES;
            [imageView setImage:image];
            [_scrollView addSubview:imageView];

            UITapGestureRecognizer *tapGs
                    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTap:)];
            [imageView addGestureRecognizer:tapGs];
        }

        _scrollView.contentSize = CGSizeMake(imageCount * self.bounds.size.width, self.bounds.size.height);
    }

    UIPageControl *pageControl = [[UIPageControl alloc] init];

    pageControl.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 10);
    pageControl.hidesForSinglePage = YES;
    pageControl.numberOfPages = imageCount;

    [self addSubview:pageControl];
    _pagedControl = pageControl;
}

#pragma mark - 外部调用接口

- (BOOL)startPlay
{
    //NOTICE: 这里是为了统计第一次展示
    if (self.delegate && [self.delegate respondsToSelector:@selector(didScrolledToIndex:)])
    {
        [self.delegate didScrolledToIndex:_pagedControl.currentPage];
    }

    if (!self.isAutoPaly)
    {
        return NO;
    }


    if (_autoPlayTimer != nil)
    {
        if ([_autoPlayTimer isValid])
        {
            [_autoPlayTimer invalidate];
            _autoPlayTimer = nil;
        }
    }

    PGAssert(self.playInterval > 0, @"设置的播放时间不合法");

    if (_autoPlayTimer == nil)
    {
        _autoPlayTimer = [NSTimer scheduledTimerWithTimeInterval:self.playInterval
                                                          target:self
                                                        selector:(@selector(scrolToNext))
                                                        userInfo:nil
                                                         repeats:YES];
        _isPlaying = YES;
    }

    return YES;
}


- (BOOL)stopPlay
{
    if (!self.isAutoPaly)
    {
        return NO;
    }

    if (_autoPlayTimer != nil)
    {
        if ([_autoPlayTimer isValid])
        {
            [_autoPlayTimer invalidate];
            _autoPlayTimer = nil;
        }
    }

    _isPlaying = NO;

    return YES;
}


- (BOOL)pausePlay
{
    if (!self.isAutoPaly)
    {
        return NO;
    }

    if (_isPlaying)
    {
        if (_autoPlayTimer != nil)
        {
            if ([_autoPlayTimer isValid])
            {
                [_autoPlayTimer invalidate];
                _autoPlayTimer = nil;
            }
        }
    }

    return YES;
}


- (BOOL)resumePlay
{
    if (!self.isAutoPaly)
    {
        return NO;
    }

    if (_isPlaying)
    {
        [self startPlay];
    }

    return YES;
}


- (void)scrolToNext
{
    [self performSelectorOnMainThread:@selector(scrolToNextOnMainTheard)
                           withObject:nil
                        waitUntilDone:YES];
}


- (void)scrolToNextOnMainTheard
{
    if (_isScrollToRight)
    {
        if (_pagedControl.currentPage < _pagedControl.numberOfPages)
        {
            if (_pagedControl.currentPage == 0)
            {
                [_scrollView scrollRectToVisible:CGRectMake(self.bounds.size.width,
                                                            0,
                                                            self.bounds.size.width,
                                                            self.bounds.size.height)
                                        animated:NO];
            }

            [_scrollView scrollRectToVisible:CGRectMake((_pagedControl.currentPage + 2) * self.bounds.size.width,
                                                        0,
                                                        self.bounds.size.width,
                                                        self.bounds.size.height)
                                    animated:YES];
        }
    }
    else
    {
        if (_pagedControl.currentPage >= 0)
        {
            if (_pagedControl.currentPage == 0)
            {
                [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentSize.width - self.bounds.size.width,
                                                            0,
                                                            self.bounds.size.width,
                                                            self.bounds.size.height)
                                        animated:NO];
                [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentSize.width - self.bounds.size.width * 2,
                                                            0,
                                                            self.bounds.size.width,
                                                            self.bounds.size.height)
                                        animated:YES];
            }
            else
            {
                const NSInteger page = _pagedControl.numberOfPages + 2 - _pagedControl.currentPage;
                const CGFloat x = _scrollView.contentSize.width - page * self.bounds.size.width;
                const struct CGRect rect = CGRectMake(x,
                                                      0,
                                                      self.bounds.size.width,
                                                      self.bounds.size.height);
                [_scrollView scrollRectToVisible:rect animated:YES];
            }
        }
    }

//    PGLogDebug(@"currentPage = %d", (int)_pagedControl.currentPage);
}


- (void)handleImageViewTap:(UITapGestureRecognizer *)aTapGs
{
    UIView *tapView = [aTapGs view];
    NSInteger tag = (tapView.tag - PGPagedScroll_ImageViewBaseTag);

    NSInteger selectIndex;

    if (_isRepeat)
    {
        selectIndex = tag / 100 - 1;
    }
    else
    {
        selectIndex = tag / 100;
    }

    PGLogDebug(@"selectIndex = %zd, tag = %zd", selectIndex, tag);
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(didSelectedAtIndex:)]))
    {
        [self.delegate didSelectedAtIndex:selectIndex];
    }
}

#pragma mark scrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_isAutoPaly && _isRepeat)
    {
        [self pausePlay];
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isAutoPaly && _isRepeat)
    {
        [self resumePlay];
//        PGLogDebug(@"currentPage = %d", (int)_pagedControl.currentPage);
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRepeat || (self.isAutoPaly))
    {
        if (scrollView.contentOffset.x > _scrollView.contentSize.width - self.bounds.size.width + 10)
        {
            [_scrollView scrollRectToVisible:CGRectMake(self.bounds.size.width,
                                                        0,
                                                        self.bounds.size.width,
                                                        self.bounds.size.height)
                                    animated:NO];
        }
        else if (scrollView.contentOffset.x < self.bounds.size.width - 10)
        {
            [_scrollView scrollRectToVisible:CGRectMake(scrollView.contentSize.width - self.bounds.size.width,
                                                        0,
                                                        self.bounds.size.width,
                                                        self.bounds.size.height)
                                    animated:NO];
        }

        _lastPage = _pagedControl.currentPage;
        _pagedControl.currentPage
                = (NSInteger)((scrollView.contentOffset.x - self.bounds.size.width) / scrollView.frame.size.width);
        if (scrollView.contentOffset.x > (scrollView.contentSize.width - self.bounds.size.width * 2))
        {
            _pagedControl.currentPage = 0;
        }
    }
    else
    {
        _lastPage = _pagedControl.currentPage;
        _pagedControl.currentPage = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
    }

    if (_lastPage != _pagedControl.currentPage)
    {
        //表示发生切换
        if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(didScrolledToIndex:)]))
        {
            [self.delegate didScrolledToIndex:_pagedControl.currentPage];
        }
    }
}


- (void)removeFromSuperview
{
    if (_autoPlayTimer != nil)
    {
        if ([_autoPlayTimer isValid])
        {
            [_autoPlayTimer invalidate];
            _autoPlayTimer = nil;
        }
    }

    [super removeFromSuperview];
}


@end
