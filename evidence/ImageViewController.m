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

	_imageView = (UIImageView *) [_scrollView addConstrainedSubview:[[UIImageView alloc] initWithImage:_image]];

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

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	CGSize size = self.view.frame.size;
	_scrollView.minimumZoomScale = MIN(size.width / _image.size.width, size.height / _image.size.height);
	_scrollView.zoomScale = _scrollView.minimumZoomScale;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

@end