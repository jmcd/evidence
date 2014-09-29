#import "ImageViewController.h"
#import "NSLayoutConstraint+AutoLayout.h"
#import "UIView+AutoLayout.h"

@interface ImageViewController () <UIScrollViewDelegate>
@end

@implementation ImageViewController {
	UIImageView *_imageView;
	UIImage *_image;
	UIScrollView *_scrollView;
	BOOL _b;
}

- (instancetype)initWithImage:(UIImage *)image {
	self = [super init];
	if (self) {
		_image = image;
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];

	_scrollView = (UIScrollView *) [self.view addConstrainedSubview:[[UIScrollView alloc] init]];
	_scrollView.contentSize = _image.size;
	_scrollView.maximumZoomScale = 1;
	[self setMinimumZoomForSize:self.view.frame.size];
	//_scrollView.minimumZoomScale = MIN(self.view.frame.size.width / _image.size.width, self.view.frame.size.height / _image.size.height);
	_scrollView.delegate = self;

	//[self zzzzzz];
	_imageView = (UIImageView *) [_scrollView addConstrainedSubview:[[UIImageView alloc] initWithImage:_image]];

	_scrollView.zoomScale = _scrollView.minimumZoomScale;
	NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView, _imageView);

	[self.view addManyConstraints:@[

		[NSLayoutConstraint constraintsWithVisualFormats:@[
			@"V:|[_scrollView]|",
			@"H:|[_scrollView]|",
			@"V:|[_imageView]|",
			@"H:|[_imageView]|",

		] options:0 metrics:nil views:views],

	]];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
	NSLog(@"viewWillTransitionToSize");

	CGFloat pre = _scrollView.minimumZoomScale;
	CGSize cgSize = size;
	[self setMinimumZoomForSize:cgSize];
	_scrollView.zoomScale = _scrollView.minimumZoomScale;

	NSLog(@"pre %.2f post %.2f", pre, _scrollView.minimumZoomScale);
}

- (void)setMinimumZoomForSize:(CGSize)size {
	NSLog(@"size %.2f, %.2f", size.width, size.height);
	_scrollView.minimumZoomScale = MIN(size.width / _image.size.width, size.height / _image.size.height);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
	NSLog(@"willTransitionToTraitCollection");
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

@end