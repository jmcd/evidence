#import "ImageViewController.h"
#import "NSLayoutConstraint+AutoLayout.h"
#import "UIView+AutoLayout.h"

@interface ImageViewController () <UIScrollViewDelegate>
@end

@implementation ImageViewController {
	UIImageView *_imageView;
	UIImage *_image;
	UIScrollView *_scrollView;
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
	_scrollView.delegate = self;

	_imageView = [[UIImageView alloc] initWithImage:_image];
	_imageView.translatesAutoresizingMaskIntoConstraints = YES;
	[_scrollView addSubview:_imageView];

	NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView);

	[self.view addManyConstraints:@[
		[NSLayoutConstraint constraintsWithVisualFormats:@[
			@"V:|[_scrollView]|",
			@"H:|[_scrollView]|",
		] options:0 metrics:nil views:views],
	]];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	CGSize size = self.view.frame.size;

	CGSize imageSize = _image.size;

	CGFloat zoomScale = MIN(size.width / imageSize.width, size.height / imageSize.height);

	_scrollView.minimumZoomScale = zoomScale;
	_scrollView.zoomScale = zoomScale;

	[self centerImageViewInScrollView];
}

- (void)centerImageViewInScrollView {

	CGFloat h = (_scrollView.bounds.size.width - _imageView.bounds.size.width * _scrollView.zoomScale) / 2.0;
	CGFloat v = (_scrollView.bounds.size.height - _imageView.bounds.size.height * _scrollView.zoomScale) / 2.0;

	_scrollView.contentInset = UIEdgeInsetsMake(v, h, v, h);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	if (scale == scrollView.minimumZoomScale) {
		[self centerImageViewInScrollView];
	}
}

@end