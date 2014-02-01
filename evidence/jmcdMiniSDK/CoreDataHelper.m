#import "CoreDataHelper.h"

@implementation CoreDataHelper {
}
+ (CoreDataHelper *)instance {
	static CoreDataHelper *_instance = nil;

	@synchronized (self) {
		if (_instance == nil) {
			_instance = [[self alloc] init];
		}
	}

	return _instance;
}

- (id)init {
	self = [super init];
	if (self) {

		NSString *modelFilename = @"Model.momd";
		NSString *storeFilename = @"Model.sqlite";

		NSURL *URL = [[NSBundle mainBundle] URLForResource:modelFilename withExtension:nil];
		ZAssert(URL, @"error constructing url for filename %@", modelFilename);

		NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:URL];
		ZAssert(model, @"error init'ing model with url %@", URL.absoluteString);

		//

		NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
		ZAssert(coordinator, @"error init'ing persistent-store-coordinator with model %@", model);

		//

		NSArray *documentDirectoryArray = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
		NSURL *storeURL = [[documentDirectoryArray lastObject] URLByAppendingPathComponent:storeFilename];

		//[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

		NSError *error;
		NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];

		if (error.code == 134100 && error.domain == NSCocoaErrorDomain) {
			DLog(@"deleting incompatible model database");
			error = nil;
			[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

			store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
		}

		ZAssert(store, @"error adding new persistent store of type %@ at url %@", NSSQLiteStoreType, storeURL.absoluteString);

		NSManagedObjectContext *mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		mainQueueContext.persistentStoreCoordinator = coordinator;

		self.mainQueueContext = mainQueueContext;
	}

	return self;
}

- (void)saveMainQueueContext {
	NSManagedObjectContext *context = self.mainQueueContext;
	[self saveContext:context];
}

- (NSArray *)executeFetchRequestOnMainQueueContext:(NSFetchRequest *)request {
	NSError *error;
	NSArray *result = [self.mainQueueContext executeFetchRequest:request error:&error];
	ZAssert(result, @"error executing fetch request: %@, %@", error.localizedDescription, error.userInfo);
	return result;
}

- (NSUInteger)countForFetchRequestOnMainQueueContext:(NSFetchRequest *)request {
	NSError *error;
	NSUInteger result = [self.mainQueueContext countForFetchRequest:request error:&error];
	ZAssert(error == nil, @"error executing fetch request: %@, %@", error.localizedDescription, error.userInfo);
	return result;
}

- (void)saveContext:(NSManagedObjectContext *)context {
	if (!context) return;
	if (![context hasChanges]) return;

	NSError *error = nil;
	ZAssert([context save:&error], @"error saving context: %@, %@", [error localizedDescription], [error userInfo]);
}

- (NSManagedObject *)existingObjectWithID:(NSManagedObjectID *)objectID inContext:(NSManagedObjectContext *)context {
	NSError *error;
	NSManagedObject *object = [context existingObjectWithID:objectID error:&error];
	ZAssert(object, @"error fetching existing object: %@, %@", error.localizedDescription, error.userInfo);
	return object;
}

- (NSManagedObject *)existingObjectWithID:(NSManagedObjectID *)objectID {
	return [self existingObjectWithID:objectID inContext:self.mainQueueContext];
}
@end