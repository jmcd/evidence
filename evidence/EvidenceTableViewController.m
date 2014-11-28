#import <MobileCoreServices/MobileCoreServices.h>
#import "EvidenceTableViewController.h"
#import "UIView+AutoLayout.h"
#import "CoreDataHelper.h"
#import "Evidence.h"
#import "NSLayoutConstraint+AutoLayout.h"

#import "CalendarDate.h"
#import "EvidenceTableViewCell.h"
#import "ConventionalDateFormatter.h"
#import "EvidenceFactory.h"
#import "Notifications.h"
#import "FetchedResultsControllerTableViewDelegate.h"
#import "FetchedResultsControllerTableViewDelegateDelegate.h"
#import "DetailViewController.h"

static NSString *EvidenceTableViewControllerCellReuseIdentifier = @"EvidenceTableViewControllerCellReuseIdentifier";

@interface EvidenceTableViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FetchedResultsControllerTableViewDelegateDelegate>
@end

@implementation EvidenceTableViewController {
	UITableView *_tableView;
	NSFetchedResultsController *_fetchedResultsController;
	NSString *_addedEvidenceType;
	CalendarDate *_today;
	ConventionalDateFormatter *_conventionalDateFormatter;
	FetchedResultsControllerTableViewDelegate *_fetchedResultsControllerTableViewDelegate;

	UIBarButtonItem *_addEvidenceButtonItem;
	UIBarButtonItem *_trashBarButtonItem;
	UIPopoverController *_popover;
}

#pragma mark - alerts, sheets and other presented view controllers

- (void)presentPickEvidenceTypeSheet {
	[self presentViewController:[self createPickEvidenceTypeSheet] animated:YES completion:^() {}];
}

- (void)presentCustomEvidenceTypeAlert {
	[self presentViewController:[self createCustomEvidenceTypeAlert] animated:YES completion:^() {}];
}

- (void)presentDeleteAllAlert {
	[self presentViewController:[self createDeleteAllAlert] animated:YES completion:^() {}];
}

- (void)presentOpenSettingsAlert {
	[self presentViewController:[self createOpenSettingsAlert] animated:YES completion:^() {}];
}

- (void)presentImagePickerController:(UIImagePickerControllerCameraCaptureMode)cameraCaptureMode {
	UIImagePickerController *imagePickerController = [self createImagePickerController];
	imagePickerController.cameraCaptureMode = cameraCaptureMode;
	[self.splitViewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (UIAlertController *)createDeleteAllAlert {
	__weak EvidenceTableViewController *welf = self;
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete all evidence?" message:nil preferredStyle:UIAlertControllerStyleAlert];
	alert.popoverPresentationController.barButtonItem = _trashBarButtonItem;
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *aa) {}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *aa) {
		[welf deleteAllEvidence];
	}]];
	return alert;
}

- (UIAlertController *)createOpenSettingsAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Open the Settings App?" message:nil preferredStyle:UIAlertControllerStyleAlert];
	alert.popoverPresentationController.barButtonItem = _addEvidenceButtonItem;
	[alert addAction:[UIAlertAction actionWithTitle:@"Stay Here" style:UIAlertActionStyleDefault handler:^(UIAlertAction *aa) {}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *aa) {
		NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
		[[UIApplication sharedApplication] openURL:appSettings];
	}]];
	return alert;
}

- (UIAlertController *)createPickEvidenceTypeSheet {
	__weak EvidenceTableViewController *welf = self;
	UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"What are you collecting evidence of?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	sheet.popoverPresentationController.barButtonItem = _addEvidenceButtonItem;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	for (int i = 0; i < 6; i++) {
		NSString *key = [NSString stringWithFormat:@"type_%d_preference", i];
		NSString *string = [defaults objectForKey:key];
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if (string.length > 0) {
			UIAlertAction *action = [UIAlertAction actionWithTitle:string style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
				[welf evidenceTypeWasPicked:string];
			}];

			[sheet addAction:action];
		}
	}

	[sheet addAction:[UIAlertAction actionWithTitle:@"Edit this list in the Settings app..." style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
		[welf presentOpenSettingsAlert];
	}]];

	[sheet addAction:[UIAlertAction actionWithTitle:@"Something else, a one-off..." style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
		[welf presentCustomEvidenceTypeAlert];
	}]];

	[sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	return sheet;
}

- (UIAlertController *)createCustomEvidenceTypeAlert {
	__weak EvidenceTableViewController *welf = self;
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"What are you collecting evidence of?" message:nil preferredStyle:UIAlertControllerStyleAlert];
	alert.popoverPresentationController.barButtonItem = _addEvidenceButtonItem;
	[alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
	}];

	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
		UITextField *textField = alert.textFields[0];
		NSString *evidenceType = textField.text;
		[welf evidenceTypeWasPicked:evidenceType];
	}]];
	return alert;
}

- (UIImagePickerController *)createImagePickerController {
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.popoverPresentationController.sourceView = self.splitViewController.popoverPresentationController.sourceView;
	imagePickerController.popoverPresentationController.sourceRect = self.splitViewController.popoverPresentationController.sourceRect;
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
	imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
	imagePickerController.delegate = self;
	return imagePickerController;
}

- (void)deleteAllEvidence {
	NSArray *allEvidences = [[CoreDataHelper instance] executeFetchRequestOnMainQueueContext:[NSFetchRequest fetchRequestWithEntityName:[Evidence entityName]]];
	for (id evidence in allEvidences) {
		[[CoreDataHelper instance].mainQueueContext deleteObject:evidence];
	}
	[[CoreDataHelper instance] saveMainQueueContext];
}

- (void)evidenceTypeWasPicked:(NSString *)evidenceType {
	_addedEvidenceType = evidenceType;
	UIImagePickerControllerCameraCaptureMode captureMode = UIImagePickerControllerCameraCaptureModeVideo;
	NSString *previousMediaType = [self previousMediaTypeForEvidenceOfType:evidenceType];
	if ([previousMediaType isEqualToString:(NSString *) kUTTypeImage]) {
		captureMode = UIImagePickerControllerCameraCaptureModePhoto;
	}
	[self presentImagePickerController:captureMode];
}

- (NSString *)previousMediaTypeForEvidenceOfType:(NSString *)evidenceType {
	NSManagedObjectContext *context = [CoreDataHelper instance].mainQueueContext; //TODO: have context as dependency of controller
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Evidence entityName]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type = %@", evidenceType];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdOnDateTime" ascending:NO]]];
	fetchRequest.fetchLimit = 1;
	NSError *error;
	NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
	ZAssert(array, @"expected to be able to query previous evidence");
	Evidence *previousEvidence = array.firstObject;
	return previousEvidence.mediaType;
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

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	_conventionalDateFormatter = [[ConventionalDateFormatter alloc] init];

	_addEvidenceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentPickEvidenceTypeSheet)];
	_trashBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(presentDeleteAllAlert)];

	self.title = @"Evidence";
	self.navigationItem.rightBarButtonItem = _addEvidenceButtonItem;
	self.navigationItem.leftBarButtonItem = _trashBarButtonItem;

	_tableView = (UITableView *) [self.view addConstrainedSubview:[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped]];
	_tableView.rowHeight = 88.0;
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
	} else {
		return 0;
	}
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

	Evidence *evidence = [_fetchedResultsController objectAtIndexPath:indexPath];

	DetailViewController *detailViewController = [[DetailViewController alloc] initWithEvidence:evidence];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];

	[self showDetailViewController:navigationController sender:self];
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

	[self dismissPopover];
}

- (void)dismissPopover {
	if (_popover) {
		[_popover dismissPopoverAnimated:YES];
		_popover = nil;
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissPopover];
}

@end