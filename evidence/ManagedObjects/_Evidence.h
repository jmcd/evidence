// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Evidence.h instead.

#import <CoreData/CoreData.h>


extern const struct EvidenceAttributes {
	__unsafe_unretained NSString *createdOnDate;
	__unsafe_unretained NSString *createdOnDateTime;
	__unsafe_unretained NSString *dataFilePath;
	__unsafe_unretained NSString *mediaType;
	__unsafe_unretained NSString *thumbnailImageData;
	__unsafe_unretained NSString *type;
} EvidenceAttributes;

extern const struct EvidenceRelationships {
} EvidenceRelationships;

extern const struct EvidenceFetchedProperties {
} EvidenceFetchedProperties;









@interface EvidenceID : NSManagedObjectID {}
@end

@interface _Evidence : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EvidenceID*)objectID;





@property (nonatomic, strong) NSDate* createdOnDate;



//- (BOOL)validateCreatedOnDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdOnDateTime;



//- (BOOL)validateCreatedOnDateTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* dataFilePath;



//- (BOOL)validateDataFilePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* mediaType;



//- (BOOL)validateMediaType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* thumbnailImageData;



//- (BOOL)validateThumbnailImageData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;






@end

@interface _Evidence (CoreDataGeneratedAccessors)

@end

@interface _Evidence (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedOnDate;
- (void)setPrimitiveCreatedOnDate:(NSDate*)value;




- (NSDate*)primitiveCreatedOnDateTime;
- (void)setPrimitiveCreatedOnDateTime:(NSDate*)value;




- (NSString*)primitiveDataFilePath;
- (void)setPrimitiveDataFilePath:(NSString*)value;




- (NSString*)primitiveMediaType;
- (void)setPrimitiveMediaType:(NSString*)value;




- (NSData*)primitiveThumbnailImageData;
- (void)setPrimitiveThumbnailImageData:(NSData*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




@end
