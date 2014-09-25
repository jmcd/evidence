#import <MediaPlayer/MediaPlayer.h>
#import "VideoViewController.h"
#import "UIView+AutoLayout.h"
#import "NSLayoutConstraint+AutoLayout.h"

@implementation VideoViewController {
	UIView *_moviePlayerView;
	MPMoviePlayerController *_moviePlayerController;
	NSString *_dataFilePath;
}
- (instancetype)initWithDataFilePath:(NSString *)path {
	self = [super init];
	if (self) {
		_dataFilePath = path;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSURL *movieUrl = [NSURL fileURLWithPath:_dataFilePath];

	_moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
	_moviePlayerController.movieSourceType = MPMovieSourceTypeStreaming;

	_moviePlayerView = (UIView *) [self.view addConstrainedSubview:_moviePlayerController.view];

	NSDictionary *views = NSDictionaryOfVariableBindings(_moviePlayerView);

	[self.view addManyConstraints:@[

		[NSLayoutConstraint constraintsWithVisualFormats:@[
			@"V:|[_moviePlayerView]|",
			@"H:|[_moviePlayerView]|",

		] options:0 metrics:nil views:views],

	]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[_moviePlayerController play];
}

@end