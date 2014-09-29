#import <MobileCoreServices/MobileCoreServices.h>
#import "EvidenceTableViewController.h"
#import "UIView+AutoLayout.h"
#import "CoreDataHelper.h"
#import "Evidence.h"
#import "NSLayoutConstraint+AutoLayout.h"
#import "ActionSheetController.h"
#import "Action.h"
#import "AlertViewController.h"
#import "CalendarDate.h"
#import "EvidenceTableViewCell.h"
#import "VideoViewController.h"
#import "ImageViewController.h"
#import "ConventionalDateFormatter.h"
#import "EvidenceFactory.h"
#import "Notifications.h"
#import "FetchedResultsControllerTableViewDelegate.h"
#import "FetchedResultsControllerTableViewDelegateDelegate.h"

static NSString *EvidenceTableViewControllerCellReuseIdentifier = @"EvidenceTableViewControllerCellReuseIdentifier";

@interface EvidenceTableViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FetchedResultsControllerTableViewDelegateDelegate>
@end

@implementation EvidenceTableViewController {
	UITableView *_tableView;
	NSFetchedResultsController *_fetchedResultsController;
	NSString *_addedEvidenceType;
	ActionSheetController *_actionSheetController;
	AlertViewController *_deleteAllAlertViewController;
	CalendarDate *_today;
	AlertViewController *_alertViewController;
	UIAlertView *_alertView;
	ConventionalDateFormatter *_conventionalDateFormatter;
	FetchedResultsControllerTableViewDelegate *_fetchedResultsControllerTableViewDelegate;
	AlertViewController *_openSettingsAlertViewController;
}

- (instancetype)init {
	self = [super init];
	if (self) {

		_openSettingsAlertViewController = [[AlertViewController alloc] initWithTitle:@"Open the Settings App?" message:@"You can get back to the Evidence app with the home button."
			cancelAction:[Action actionWithTitle:@"Stay Here"]
			otherActions:@[
				[Action actionWithTitle:@"Open Settings" block:^() {
					NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
					[[UIApplication sharedApplication] openURL:appSettings];
				}]
			]
		];
	}

	return self;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Evidence *evidence = [_fetchedResultsController objectAtIndexPath:indexPath];
	NSString *string = [_conventionalDateFormatter timeStringFromDate:evidence.createdOnDateTime];
	cell.detailTextLabel.text = string;
	cell.textLabel.text = evidence.type;
	cell.imageView.image = [UIImage imageWithData:evidence.thumbnailImageData];
}

- (NSFetchRequest *)constructFetchRequest {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Evidence entityName]];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdOnDateTime" ascending:NO]]];
	return fetchRequest;
}

- (void)beginAdd {

	_alertViewController = [[AlertViewController alloc] initWithTitle:@"What are you collecting evidence of?" message:nil cancelAction:[Action actionWithTitle:@"Cancel"] otherActions:@[[Action actionWithTitle:@"OK" block:^{
		UITextField *textField = [_alertViewController.alertView textFieldAtIndex:0];
		_addedEvidenceType = textField.text;
		[self presentImagePickerController];
	}]]];

	NSMutableArray *actions = [NSMutableArray array];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	for (int i = 0; i < 6; i++) {
		NSString *key = [NSString stringWithFormat:@"type_%d_preference", i];
		NSString *string = [defaults objectForKey:key];
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (string.length > 0) {
			Action *action = [Action actionWithTitle:string block:^() {
				_addedEvidenceType = string;
				[self presentImagePickerController];
			}];
			[actions addObject:action];
		}
	}

	__weak EvidenceTableViewController *welf = self;
	Action *editInSettings = [Action actionWithTitle:@"Edit this list in the Settings app..." block:^() {
		[welf beginOpenSettings];
	}];
	[actions addObject:editInSettings];

	Action *somethingElse = [Action actionWithTitle:@"Something else, a one-off..." block:^() {
		_alertView = _alertViewController.alertView;
		_alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
		[_alertView show];
	}];
	[actions addObject:somethingElse];

	Action *cancelAction = [Action actionWithTitle:@"Cancel" block:^() {
		_addedEvidenceType = nil;
	}];

	_actionSheetController = [[ActionSheetController alloc] initWithTitle:@"What are you collecting evidence of?" cancelAction:cancelAction destructiveAction:nil otherActions:actions];

	[_actionSheetController.actionSheet showInView:self.view];
}

- (void)beginDeleteAll {

	_deleteAllAlertViewController = [[AlertViewController alloc] initWithTitle:@"Delete all evidence?" message:nil cancelAction:[Action actionWithTitle:@"Keep"] otherActions:@[
		[Action actionWithTitle:@"Delete all" block:^() {

			NSArray *allEvidences = [[CoreDataHelper instance] executeFetchRequestOnMainQueueContext:[NSFetchRequest fetchRequestWithEntityName:[Evidence entityName]]];

			for (id evidence in allEvidences) {
				[[CoreDataHelper instance].mainQueueContext deleteObject:evidence];
			}

			[[CoreDataHelper instance] saveMainQueueContext];
		}]
	]];

	[_deleteAllAlertViewController.alertView show];
}

- (void)beginOpenSettings {
	[_openSettingsAlertViewController.alertView show];
}

- (void)presentImagePickerController {

	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
	imagePickerController.delegate = self;

	[self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)presentSettings {

	NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
	[[UIApplication sharedApplication] openURL:appSettings];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	_conventionalDateFormatter = [[ConventionalDateFormatter alloc] init];

	self.title = @"Evidence";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(beginAdd)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(beginDeleteAll)];

	_tableView = (UITableView *) [self.view addConstrainedSubview:[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped]];
	[_tableView registerClass:[EvidenceTableViewCell class] forCellReuseIdentifier:EvidenceTableViewControllerCellReuseIdentifier];
	_tableView.dataSource = self;
	_tableView.delegate = self;

	NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);

	[self.view addManyConstraints:@[

		[NSLayoutConstraint constraintsWithVisualFormats:@[
			@"V:|[_tableView]|",
			@"H:|[_tableView]|",
		] options:(NSLayoutFormatOptions) 0 metrics:nil views:views],
	]];

	_today = [CalendarDate today];

	NSManagedObjectContext *context = [CoreDataHelper instance].mainQueueContext;

	_fetchedResultsControllerTableViewDelegate = [[FetchedResultsControllerTableViewDelegate alloc] initWithDelegate:self];

	NSFetchRequest *fetchRequest = [self constructFetchRequest];
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"createdOnDate" cacheName:nil];
	_fetchedResultsController.delegate = _fetchedResultsControllerTableViewDelegate;

	NSError *error;
	ZAssert([_fetchedResultsController performFetch:&error], @"error performing fetch: %@, %@", error.localizedDescription, error.userInfo);

	[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkTodayIsValid) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)checkTodayIsValid {
	CalendarDate *today = [CalendarDate today];
	if ([today isAfter:_today]) {
		_today = today;
		[_tableView reloadData];
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if ([[_fetchedResultsController sections] count] > 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	} else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EvidenceTableViewControllerCellReuseIdentifier forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([[_fetchedResultsController sections] count] > 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];

		Evidence *evidence = [sectionInfo.objects firstObject];
		NSDate *date = evidence.createdOnDate;
		return [_conventionalDateFormatter dayDescriptionStringFromDate:date releativeToToday:_today.date];
	} else {
		return nil;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[CoreDataHelper instance].mainQueueContext deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
		[[CoreDataHelper instance] saveMainQueueContext];
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	UIViewController *controller;

	Evidence *evidence = [_fetchedResultsController objectAtIndexPath:indexPath];
	if ([evidence.mediaType isEqualToString:(NSString *) kUTTypeMovie]) {
		controller = [[VideoViewController alloc] initWithDataFilePath:evidence.fixedDataFilePath];
	}

	if ([evidence.mediaType isEqualToString:(NSString *) kUTTypeImage]) {
		UIImage *image = [UIImage imageWithData:evidence.data];
		controller = [[ImageViewController alloc] initWithImage:image];
	}

	controller.title = [NSString stringWithFormat:@"%@, %@", evidence.type, [_conventionalDateFormatter longStringFromDate:evidence.createdOnDateTime]];
	[self showDetailViewController:controller sender:self];
}

#pragma mark - FetchedResultsControllerTableViewDelegateDelegate

- (UITableView *)tableViewForFetchedResultsControllerTableViewDelegate:(FetchedResultsControllerTableViewDelegate *)fetchedResultsControllerTableViewDelegate {
	return _tableView;
}

- (void)fetchedResultsControllerTableViewDelegate:(FetchedResultsControllerTableViewDelegate *)fetchedResultsControllerTableViewDelegate configureCellAtIndexPath:(NSIndexPath *)indexPath {
	[self configureCell:[_tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	NSString *mediaType = info[UIImagePickerControllerMediaType];
	NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
	UIImage *editedImage = info[UIImagePickerControllerEditedImage];
	UIImage *originalImage = info[UIImagePickerControllerOriginalImage];

	Evidence *evidence = [EvidenceFactory constructEvidenceWithMediaType:mediaType mediaUrl:mediaUrl editedImage:editedImage originalImage:originalImage evidenceType:_addedEvidenceType];

	[Notifications scheduleNotificationForEvidence:evidence];

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end