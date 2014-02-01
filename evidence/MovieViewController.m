#import <MediaPlayer/MediaPlayer.h>
#import "MovieViewController.h"
#import "UIView+AutoLayout.h"
#import "NSLayoutConstraint+AutoLayout.h"

@implementation MovieViewController {
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

    [self.view setNeedsUpdateConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_moviePlayerController play];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    [self.view removeConstraints:self.view.constraints];

    NSDictionary *views = NSDictionaryOfVariableBindings(_moviePlayerView);

    [self.view addManyConstraints:@[

        [NSLayoutConstraint constraintsWithVisualFormats:@[
            @"V:|[_moviePlayerView]|",
            @"H:|[_moviePlayerView]|",

        ] options:0 metrics:nil views:views],

    ]];
}

@end