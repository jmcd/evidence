#import <Foundation/Foundation.h>

@interface CoreDataHelper : NSObject
+ (CoreDataHelper *)instance;

@property(nonatomic, strong) NSManagedObjectContext *mainQueueContext;

- (void)saveMainQueueContext;

- (NSArray *)executeFetchRequestOnMainQueueContext:(NSFetchRequest *)request;

- (NSUInteger)countForFetchRequestOnMainQueueContext:(NSFetchRequest *)request;

- (void)saveContext:(NSManagedObjectContext *)context;

- (NSManagedObject *)existingObjectWithID:(NSManagedObjectID *)objectID;
@end