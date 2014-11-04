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

	_scrollView.backgroundColor = [UIColor redColor];

	_imageView = (UIImageView *) [_scrollView addConstrainedSubview:[[UIImageView alloc] initWithImage:_image]];

	id <UILayoutSupport> topLayoutGuide = self.topLayoutGuide;
	id <UILayoutSupport> bottomLayoutGuide = self.bottomLayoutGuide;

	NSDictionary *views = NSDictionaryOfVariableBindings(topLayoutGuide, bottomLayoutGuide, _scrollView, _imageView);

	[_scrollView addManyConstraints:@[

		[NSLayoutConstraint constraintsWithVisualFormats:@[
			@"V:|[_imageView]|",
			@"H:|[_imageView]|",

		] options:0 metrics:nil views:views],

	]];

	[self.view addManyConstraints:@[

		[NSLayoutConstraint constraintsWithVisualFormats:@[
			@"V:[topLayoutGuide][_scrollView][bottomLayoutGuide]",
			@"H:|[_scrollView]|",

		] options:0 metrics:nil views:views],

	]];


//hack to tie contentView width to the width of the screen
//	UIView *mainView = self.view;
//
//	UIImageView *contentView = _imageView;
//	NSDictionary *otherViews = NSDictionaryOfVariableBindings(mainView, contentView);
//	[mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]" options:0 metrics:0 views:otherViews]];
}

- (void)viewDidLayoutSubviews {
	DLog(@"didlayout: %@", NSStringFromCGRect(self.view.frame));
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