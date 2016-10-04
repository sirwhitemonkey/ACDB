
#import "PagingView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface PagingView (Private)
- (void)setState:(PagingState)aState;
@end

@implementation PagingView

@synthesize delegate;


- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		lastUpdatedLabel=label;
        
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		statusLabel=label;
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:view];
		activityView = view;
		
		[self setState:Normal];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)pagingLastUpdatedDate 
{
	
	if ([delegate respondsToSelector:@selector(pagingDataSourceLastUpdated:)]) {
		
		NSDate *date = [delegate pagingDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
		lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:lastUpdatedLabel.text forKey:@"messagingTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
        
	}else{
		lastUpdatedLabel.text = nil;
	}

}

- (void)setState:(PagingState)aState
{
	
	switch (aState) {
		case Pulling:
			statusLabel.text = NSLocalizedString(@"Refreshing", @"Refreshing ...");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			break;
	
        case Normal:
			if (state == Pulling){
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			statusLabel.text = NSLocalizedString(@"Normalizing", @"Normalizing ...");
			[activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			arrowImage.hidden = NO;
			arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self pagingLastUpdatedDate];
			
			break;
		case Loading:
			
			statusLabel.text = NSLocalizedString(@"Synchronising", @"Synchronising ...");
			[activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)pagingScrollViewDidScroll:(UIScrollView *)scrollView 
{	
	
	if (state == Loading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging){
		
		BOOL _loading = NO;
		if ([delegate respondsToSelector:@selector(pagingDataSourceIsLoading:)]) {
			_loading = [delegate pagingDataSourceIsLoading:self];
		}
		
		if (state == Pulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:Normal];
		
        } else if (state == Normal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:Pulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)pagingScrollViewDidEndDragging:(UIScrollView *)scrollView 
{
	
	BOOL _loading = NO;
	if ([delegate respondsToSelector:@selector(pagingDataSourceIsLoading:)]) {
		_loading = [delegate pagingDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
		if ([delegate respondsToSelector:@selector(pagingDidTriggerRefresh:)]) {
			[delegate pagingDidTriggerRefresh:self];
		}
		
		[self setState:Loading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

- (void)pagingScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:Normal];

}


@end
