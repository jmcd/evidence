#import <MediaPlayer/MediaPlayer.h>
#import "VideoViewController.h"
#import "UIView+AutoLayout.h"
#import "NSLayoutConstraint+AutoLayout.h"

@implementation VideoViewController {
	UIView *_moviePlayerView;
	MPMoviePlayerController *_moviePlayerController;
	NSString *_dataFilePath;
	BOOL _wasStarted;
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

	_moviePlayerController = [MPMoviePlayerController new];
	_moviePlayerController.movieSourceType = MPMovieSourceTypeStreaming;
	_moviePlayerController.contentURL = movieUrl;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayerController];

	_moviePlayerView = (UIView *) [self.view addConstrainedSubview:_moviePlayerController.view];

	NSDictionary *views = NSDictionaryOfVariableBindings(_moviePlayerView);

	[self.view addManyConstraints:@[

		[NSLayoutConstraint constraintsWithVisualFormats:@[
			@"V:|[_moviePlayerView]|",
			@"H:|[_moviePlayerView]|",

		] options:0 metrics:nil views:views],

	]];
}

-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)moviePlayerPlaybackStateDidChange:(NSNotification *)notification {
	if (!_wasStarted) {
		_wasStarted = _moviePlayerController.playbackState == MPMoviePlaybackStatePlaying;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!_wasStarted) {
		[_moviePlayerController play];
	}
}

@end