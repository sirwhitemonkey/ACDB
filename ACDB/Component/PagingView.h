
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum
{
	Pulling = 0,
	Normal,
	Loading,	
} PagingState;

@protocol PagingViewDelegate;
@interface PagingView : UIView
{
	__weak id delegate;
	PagingState state;
   
	UILabel *lastUpdatedLabel;
	UILabel *statusLabel;
	CALayer *arrowImage;
	UIActivityIndicatorView *activityView;
	

}

@property(nonatomic,weak) id <PagingViewDelegate> delegate;

- (void)pagingLastUpdatedDate;
- (void)pagingScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pagingScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)pagingScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol PagingViewDelegate
- (void)pagingDidTriggerRefresh:(PagingView*)view;
- (BOOL)pagingDataSourceIsLoading:(PagingView*)view;
@optional
- (NSDate*)pagingDataSourceLastUpdated:(PagingView*)view;
@end
