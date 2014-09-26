#import "AppDelegate.h"
#import "EvidenceTableViewController.h"
#import "RootViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	EvidenceTableViewController *evidenceTableViewController = [[EvidenceTableViewController alloc] init];
	//UIViewController *viewController = [UIViewController new];

	RootViewController *rootViewController = [RootViewController new];
	
	UINavigationController *navigationController0 = [[UINavigationController alloc] initWithRootViewController:evidenceTableViewController];
	UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:rootViewController];

	UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
	splitViewController.viewControllers = @[navigationController0, navigationController1];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = splitViewController;
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];

	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"type_0_preference"]) {

		NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *settingsPropertyListPath = [mainBundlePath stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];

		NSDictionary *settingsPropertyList = [NSDictionary dictionaryWithContentsOfFile:settingsPropertyListPath];

		NSMutableArray *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
		NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];

		for (int i = 0; i < [preferenceArray count]; i++) {
			NSString *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];

			if (key) {
				id value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
				[registerableDictionary setObject:value forKey:key];
			}
		}

		[[NSUserDefaults standardUserDefaults] registerDefaults:registerableDictionary];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	return YES;
}

@end