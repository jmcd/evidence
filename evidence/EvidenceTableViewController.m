#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "EvidenceTableViewController.h"
#import "UIView+AutoLayout.h"
#import "CoreDataHelper.h"
#import "Evidence.h"
#import "NSLayoutConstraint+AutoLayout.h"
#import "ActionSheetController.h"
#import "Action.h"
#import "UIImage+Util.h"
#import "AlertViewController.h"
#import "CalendarDate.h"
#import "EvidenceTableViewCell.h"
#import "VideoViewController.h"
#import "ImageViewController.h"
#import "ConventionalDateFormatter.h"
#import "VideoImageGrabber.h"

static NSString *EvidenceTableViewControllerCellReuseIdentifier = @"EvidenceTableViewControllerCellReuseIdentifier";

@interface EvidenceTableViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Evidence *evidence = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.detailTextLabel.text = [_conventionalDateFormatter timeStringFromDate:evidence.createdOnDateTime];
    cell.textLabel.text = evidence.type;
    cell.imageView.image = [UIImage imageWithData:evidence.thumbnailImageData];
}

- (NSFetchRequest *)constructFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Evidence entityName]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdOnDateTime" ascending:NO]]];
    return fetchRequest;
}

- (void)beginAdd {

    _alertViewController = [[AlertViewController alloc] initWithTitle:@"What type of evidence are you collecting?" message:nil cancelAction:[Action actionWithTitle:@"Cancel"] otherActions:@[[Action actionWithTitle:@"OK" block:^{
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

    Action *somethingElse = [Action actionWithTitle:@"Something else..." block:^() {
        _alertView = _alertViewController.alertView;
        _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [_alertView show];
    }];

    [actions addObject:somethingElse];

    Action *cancelAction = [Action actionWithTitle:@"Cancel" block:^() {
        _addedEvidenceType = nil;
    }];

    _actionSheetController = [[ActionSheetController alloc] initWithTitle:@"What type of evidence are you collecting?\n(Customize these in the Settings app)" cancelAction:cancelAction destructiveAction:nil otherActions:actions];

    [_actionSheetController.actionSheet showInView:self.view];
}

- (void)beginDeleteAll {

    _deleteAllAlertViewController = [[AlertViewController alloc] initWithTitle:@"Delete all evidence?" message:nil cancelAction:[Action actionWithTitle:@"Keep"] otherActions:@[
        [Action actionWithTitle:@"Delete all" block:^() {

            if ([NSThread isMainThread]) {

                NSArray *allEvidences = [[CoreDataHelper instance] executeFetchRequestOnMainQueueContext:[NSFetchRequest fetchRequestWithEntityName:[Evidence entityName]]];

                for (id evidence in allEvidences) {
                    [[CoreDataHelper instance].mainQueueContext deleteObject:evidence];
                }

                [[CoreDataHelper instance] saveMainQueueContext];
            }
        }]
    ]];

    [_deleteAllAlertViewController.alertView show];
}

- (void)presentImagePickerController {

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    imagePickerController.delegate = self;

    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)scheduleNotificationForEvidence:(Evidence *)evidence {
    NSNumber *delayInMinutes = (NSNumber *) [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationDelay"];
    NSTimeInterval delay = delayInMinutes.integerValue;

    NSDate *createdOnDateTime = evidence.createdOnDateTime;
    NSDate *fireDate = [createdOnDateTime dateByAddingTimeInterval:delay];

    NSString *alertBody = [NSString stringWithFormat:@"%@. %@", evidence.type, [_conventionalDateFormatter longStringFromDate:evidence.createdOnDateTime]];

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.alertBody = alertBody;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = @{@"objectID" : evidence.objectID.URIRepresentation.absoluteString};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
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

    [self.view setNeedsUpdateConstraints];

    _today = [CalendarDate today];

    NSManagedObjectContext *context = [CoreDataHelper instance].mainQueueContext;

    NSFetchRequest *fetchRequest = [self constructFetchRequest];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"createdOnDate" cacheName:nil];
    _fetchedResultsController.delegate = self;

    NSError *error;
    ZAssert([_fetchedResultsController performFetch:&error], @"error performing fetch: %@, %@", error.localizedDescription, error.userInfo);
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);

    [self.view removeConstraints:self.view.constraints];

    [self.view addManyConstraints:@[

        [NSLayoutConstraint constraintsWithVisualFormats:@[
            @"V:|[_tableView]|",
            @"H:|[_tableView]|",
        ] options:(NSLayoutFormatOptions) 0 metrics:nil views:views],
    ]];
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
    } else
        return nil;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController *controller;

    Evidence *evidence = [_fetchedResultsController objectAtIndexPath:indexPath];
    if ([evidence.mediaType isEqualToString:(NSString *) kUTTypeMovie]) {
        controller = [[VideoViewController alloc] initWithDataFilePath:evidence.dataFilePath];
    }

    if ([evidence.mediaType isEqualToString:(NSString *) kUTTypeImage]) {
        UIImage *image = [UIImage imageWithData:evidence.data];
        controller = [[ImageViewController alloc] initWithImage:image];
    }

    controller.title = [NSString stringWithFormat:@"%@, %@", evidence.type, [_conventionalDateFormatter longStringFromDate:evidence.createdOnDateTime]];
    [self.navigationController pushViewController:controller animated:YES];
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
    atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
    atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
    newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = _tableView;

    switch (type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView endUpdates];
}

#pragma mark - UINavigationControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    DLog(@"");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DLog(@"");

    UIImage *image;

    NSString *mediaType = info[UIImagePickerControllerMediaType];

    Evidence *evidence = [Evidence insertInManagedObjectContext:[CoreDataHelper instance].mainQueueContext];
    evidence.mediaType = mediaType;
    evidence.type = _addedEvidenceType;

    // Set the data of the evidence, and determine an image to be converted into a thumbnail
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage]) {
        image = info[UIImagePickerControllerEditedImage];
        if (!image) {
            image = info[UIImagePickerControllerOriginalImage];
        }
        [evidence setDataWithImageData:UIImageJPEGRepresentation(image, 1)];
    } else if ([mediaType isEqualToString:(NSString *) kUTTypeMovie]) {
        NSURL *url = info[@"UIImagePickerControllerMediaURL"];
        image = [VideoImageGrabber imageFromMovieAtURL:url];
        [evidence setDataWithCopyOfContentsOfVideoURL:url];
    } else {
        ZAssert(NO, @"");
    }

    CGSize thumbnailSize = CGSizeMake(100, 100);
    UIImage *thumbnailImage = [UIImage imageWithImage:image scaledToFillSize:thumbnailSize];
    evidence.thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1);

    [[CoreDataHelper instance] saveMainQueueContext];

    [self scheduleNotificationForEvidence:evidence];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DLog(@"");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end